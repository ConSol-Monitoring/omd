#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use Sys::Hostname;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
    use FindBin;
    use lib "$FindBin::Bin/lib/lib/perl5";
}

chomp(my $os = qx(./distro));

#plan( tests => 212 );
plan( skip_all => "this distribution does not run with systemd" ) if ! -x "/bin/systemctl";
my $snmptrap = -x "/bin/snmptrap" ? "/bin/snmptrap" : -x "/usr/bin/snmptrap" ? "/usr/bin/snmptrap" : undef;
plan( skip_all => "this server cannot send traps" ) if ! defined $snmptrap;
my $snmptrapd = -x "/usr/sbin/snmptrapd" ? "/usr/sbin/snmptrapd" : -x "/usr/bin/snmptrapd" ? "/usr/bin/snmptrapd" : undef;
plan( skip_all => "this server cannot receive traps" ) if ! defined $snmptrapd;

##################################################
# create our test sites
my $omd_bin = TestUtils::get_omd_bin();
my $site1    = TestUtils::create_test_site('testsnmp1') or TestUtils::bail_out_clean("no further testing without site");
my $site2    = TestUtils::create_test_site('testsnmp2') or TestUtils::bail_out_clean("no further testing without site");
my $curl    = '/usr/bin/curl --user root:root';
my $systemctl = "/bin/systemctl";

# according to /opt/omd/versions/default/share/samplicate/README.systemd...
TestUtils::test_command({ cmd => "/bin/cp /opt/omd/versions/default/share/samplicate/*.service /etc/systemd/system" });
# reduce sleep. just for the tests
TestUtils::test_command({ cmd => "/bin/sed -ri 's/60/3/g' /opt/omd/versions/default/bin/samplicate_watch" });

# register the services
TestUtils::test_command({ cmd => "$systemctl enable samplicate_watch", errlike => $os =~ /SLES 12/ ? undef : '/Created/' });
TestUtils::test_command({ cmd => "$systemctl enable samplicate", errlike => $os =~ /SLES 12/ ? undef : '/Created/' });
TestUtils::test_command({ cmd => "$systemctl status samplicate_watch", like => '/inactive/', exit => 3 });

# start the watchdog service
TestUtils::test_command({ cmd => "$systemctl stop snmptrapd.service", exit => undef });
TestUtils::test_command({ cmd => "$systemctl start samplicate_watch" });
TestUtils::test_command({ cmd => "$systemctl status samplicate_watch", like => '/running/' });
TestUtils::test_command({ cmd => '/bin/ps -ef | grep samplicate', like => '/samplicate_watch/' });

# start site1 with a local snmptrapd. find out the listener port
TestUtils::test_command({ cmd => $omd_bin." config $site1 set SNMPTRAPD on" });
TestUtils::test_command({ cmd => $omd_bin." start $site1", like => '/Starting dedicated SNMPTrapd for site.+OK/' });
my $site1port = { cmd => $omd_bin." config $site1 show SNMPTRAPD_UDP_PORT", like => '/\d+/' };
TestUtils::test_command($site1port);
$site1port = $site1port->{stdout};
chomp $site1port;

# now the watchdow must have started the samplicate service
TestUtils::test_command({ cmd => "$systemctl status samplicate", like => '/running/', waitfor => 'running' });
# the samplicate process must send traps to site1's listening port
TestUtils::test_command({ cmd => '/bin/ps -ef | grep samplicate', like => '/samplicate.pid -S.+127\.0\.0\.1\/'.$site1port.'/', waitfor => "samplicate.pid.*$site1port" });

# now start site2 which has no snmptrapd
TestUtils::test_command({ cmd => $omd_bin." config $site2 set SNMPTRAPD off" });
TestUtils::test_command({ cmd => $omd_bin." start $site2" });

# nothing should have changed
TestUtils::test_command({ cmd => "$systemctl status samplicate", like => '/running/', waitfor => 'running' });
TestUtils::test_command({ cmd => '/bin/ps -ef | grep samplicate', like => '/samplicate.pid -S.+127\.0\.0\.1\/'.$site1port.'/', waitfor => "samplicate.pid.*$site1port" });

# now restart site2 but with an snmptrapd
TestUtils::test_command({ cmd => $omd_bin." stop $site2" });
TestUtils::test_command({ cmd => $omd_bin." config $site2 set SNMPTRAPD on" });
TestUtils::test_command({ cmd => $omd_bin." start $site2", like => '/Starting dedicated SNMPTrapd for site.+OK/' });
my $site2port = { cmd => $omd_bin." config $site2 show SNMPTRAPD_UDP_PORT", like => '/\d+/' };
TestUtils::test_command($site2port);
$site2port = $site2port->{stdout};
chomp $site2port;

# the watchdog has restarted the samplicate service which now has two targets
TestUtils::test_command({ cmd => "$systemctl status samplicate", like => '/running/', waitfor => 'running' });
TestUtils::test_command({ cmd => '/bin/ps -ef | grep samplicate', like => '/samplicate.pid -S.+127\.0\.0\.1\/'.$site1port.'/', waitfor => 'samplicate.pid\ \-S.+127\.0\.0\.1\/'.$site1port });
TestUtils::test_command({ cmd => '/bin/ps -ef | grep samplicate', like => '/samplicate.pid -S.+127\.0\.0\.1\/'.$site2port.'/', waitfor => 'samplicate.pid\ \-S.+127\.0\.0\.1\/'.$site2port });


# predefined communities are sitename & public
TestUtils::test_command({ cmd => "$snmptrap -Ln -v 2c -c $site1 127.0.0.1 '' 1.3.6.1.4.1.8072.2.3.0.1 1.3.6.1.4.1.8072.2.3.2.1 i 11111" });
TestUtils::test_command({ cmd => "$snmptrap -Ln -v 2c -c $site2 127.0.0.1 '' 1.3.6.1.4.1.8072.2.3.0.1 1.3.6.1.4.1.8072.2.3.2.1 i 22222" });
TestUtils::test_command({ cmd => "$snmptrap -Ln -v 2c -c public 127.0.0.1 '' 1.3.6.1.4.1.8072.2.3.0.1 1.3.6.1.4.1.8072.2.3.2.1 i 33333" });
TestUtils::test_command({ cmd => "$snmptrap -Ln -v 2c -c gsjcuh 127.0.0.1 '' 1.3.6.1.4.1.8072.2.3.0.1 1.3.6.1.4.1.8072.2.3.2.1 i 44444" });

TestUtils::wait_for_file("/omd/sites/$site1/var/log/snmp/traps.log");
TestUtils::wait_for_file("/omd/sites/$site2/var/log/snmp/traps.log");
TestUtils::test_command({ cmd => "/bin/grep 11111 /omd/sites/$site1/var/log/snmp/traps.log", like => '/____.1.3.6.1.4.1.8072.2.3.2.1 11111/', exit => undef });
TestUtils::test_command({ cmd => "/bin/grep 11111 /omd/sites/$site2/var/log/snmp/traps.log", unlike => '/____.1.3.6.1.4.1.8072.2.3.2.1 11111/', exit => undef });
TestUtils::test_command({ cmd => "/bin/grep 22222 /omd/sites/$site1/var/log/snmp/traps.log", unlike => '/____.1.3.6.1.4.1.8072.2.3.2.1 22222/', exit => undef });
TestUtils::test_command({ cmd => "/bin/grep 22222 /omd/sites/$site2/var/log/snmp/traps.log", like => '/____.1.3.6.1.4.1.8072.2.3.2.1 22222/', exit => undef });
TestUtils::test_command({ cmd => "/bin/grep 33333 /omd/sites/$site1/var/log/snmp/traps.log", like => '/____.1.3.6.1.4.1.8072.2.3.2.1 33333/', exit => undef });
TestUtils::test_command({ cmd => "/bin/grep 33333 /omd/sites/$site2/var/log/snmp/traps.log", like => '/____.1.3.6.1.4.1.8072.2.3.2.1 33333/', exit => undef });
TestUtils::test_command({ cmd => "/bin/grep 44444 /omd/sites/$site1/var/log/snmp/traps.log", unlike => '/____.1.3.6.1.4.1.8072.2.3.2.1 44444/', exit => undef });
TestUtils::test_command({ cmd => "/bin/grep 44444 /omd/sites/$site2/var/log/snmp/traps.log", unlike => '/____.1.3.6.1.4.1.8072.2.3.2.1 44444/', exit => undef });

TestUtils::test_command({ cmd => $omd_bin." stop $site1" });
TestUtils::test_command({ cmd => $omd_bin." config $site1 set SNMPTRAPD off" });
TestUtils::test_command({ cmd => $omd_bin." start $site1", unlike => '/Starting dedicated SNMPTrapd for site.+OK/' });

# restart site1 without snmptrapd
TestUtils::test_command({ cmd => "$systemctl status samplicate", like => '/running/', waitfor => 'running' });
# site1 is no longer a target
TestUtils::test_command({ cmd => '/bin/ps -ef | grep samplicate', unlike => '/samplicate.pid -S.+127\.0\.0\.1\/'.$site1port.'/', waitfor => "!samplicate.pid.*$site1port" });
TestUtils::test_command({ cmd => '/bin/ps -ef | grep samplicate', like => '/samplicate.pid -S.+127\.0\.0\.1\/'.$site2port.'/', waitfor => "samplicate.pid.*$site2port" });

# restart site2 without snmptrapd
TestUtils::test_command({ cmd => $omd_bin." stop $site2" });
TestUtils::test_command({ cmd => $omd_bin." config $site2 set SNMPTRAPD off" });
TestUtils::test_command({ cmd => $omd_bin." start $site2", unlike => '/Starting dedicated SNMPTrapd for site.+OK/' });

# there are no more targets. the watchdog has stopped samplicate entirely
TestUtils::test_command({ cmd => "$systemctl status samplicate", like => '/exited/', exit => 3, waitfor => 'inactive' });
TestUtils::test_command({ cmd => '/bin/ps -ef | grep samplicate', unlike => '/samplicate.pid -S.+127\.0\.0\.1\/'.$site1port.'/' });
TestUtils::test_command({ cmd => '/bin/ps -ef | grep samplicate', unlike => '/samplicate.pid -S.+127\.0\.0\.1\/'.$site2port.'/' });
TestUtils::test_command({ cmd => '/bin/ps -ef | grep samplicate', unlike => '/samplicate.pid -S/' });

#
##Clean up
TestUtils::test_command({ cmd => $omd_bin." stop $site1" });
TestUtils::remove_test_site($site1);
TestUtils::test_command({ cmd => $omd_bin." stop $site2" });
TestUtils::remove_test_site($site2);
#
TestUtils::test_command({ cmd => "$systemctl stop samplicate_watch" });
TestUtils::test_command({ cmd => "$systemctl stop samplicate" });
TestUtils::test_command({ cmd => "$systemctl disable samplicate_watch", errlike => $os =~ /SLES 12/ ? undef : '/Removed/' });
TestUtils::test_command({ cmd => "$systemctl disable samplicate", errlike => $os =~ /SLES 12/ ? undef : '/Removed/' });
TestUtils::test_command({ cmd => "/bin/rm -f /etc/systemd/system/samplicate_watch.service" });
TestUtils::test_command({ cmd => "/bin/rm -f /etc/systemd/system/samplicate.service" });

done_testing();
