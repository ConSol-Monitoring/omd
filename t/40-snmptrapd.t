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

chomp(my $os = qx(./build/distro));

plan( skip_all => "this test does not run inside docker" ) if TestUtils::is_docker();
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

my $selinux = 0;
if(`getenforce 2>/dev/null` =~ m/Enforcing/) {
    `setenforce 0 >/dev/null 2>&1`; # does not work with se linux enabled, samplicate daemon cannot read the tmp file
    $selinux = 1;
    diag("disabled selinux");
}

# according to /opt/omd/versions/default/share/samplicate/README.systemd...
TestUtils::test_command({ cmd => "/bin/cp /opt/omd/versions/default/share/samplicate/*.service /etc/systemd/system" });
# reduce sleep. just for the tests
TestUtils::test_command({ cmd => "/bin/sed -ri 's/60/3/g' /opt/omd/versions/default/bin/samplicate_watch" });

# register the services
TestUtils::test_command({ cmd => "$systemctl enable samplicate_watch", errlike => $os =~ /SLES 12/ ? undef : '/Created/' });
TestUtils::test_command({ cmd => "$systemctl enable samplicate", errlike => $os =~ /SLES 12/ ? undef : '/Created/' });
TestUtils::test_command({ cmd => "$systemctl status samplicate_watch", like => '/inactive/', exit => 3 });

# start the watchdog service
TestUtils::test_command({ cmd => "$systemctl stop snmptrapd.socket", exit => undef, errlike => undef });
TestUtils::test_command({ cmd => "$systemctl stop snmptrapd", exit => undef });
TestUtils::test_command({ cmd => "$systemctl start samplicate_watch" });
TestUtils::test_command({ cmd => "$systemctl status samplicate_watch", like => '/running/' });
TestUtils::test_command({ cmd => '/bin/ps -ef | grep samplicate', like => '/samplicate_watch/' });

# start site1 with a local snmptrapd. find out the listener port
TestUtils::test_command({ cmd => $omd_bin." config $site1 set SNMPTRAPD on" });
TestUtils::test_command({ cmd => $omd_bin." start $site1", like => '/Starting snmptrapd\.+OK/' });
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
TestUtils::test_command({ cmd => $omd_bin." start $site2", like => '/Starting snmptrapd\.+OK/' });
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

##################################################
#
# Phase 2: the snmptrapd mirror method
# (phase 1 tested the legacy samplicate method; both must work)
#
my $tt = '/opt/omd/versions/default/bin/trap_targets';
if( -x $tt
    and -x '/opt/omd/versions/default/bin/snmptrapd_mirror_watch'
    and -x '/opt/omd/versions/default/bin/snmptrapd_mirror_start'
    and -d '/opt/omd/versions/default/share/snmptrapd_mirror' ) {

    # install the mirror's units and register them
    TestUtils::test_command({ cmd => "/bin/cp /opt/omd/versions/default/share/snmptrapd_mirror/*.service /etc/systemd/system" });
    TestUtils::test_command({ cmd => "$systemctl daemon-reload" });
    # enable the watcher (operator flow). the mirror unit is NOT auto-enabled
    # by this (Requires= does not pull enablement in) - the watcher starts it
    TestUtils::test_command({ cmd => "$systemctl enable snmptrapd_mirror_watch", errlike => $os =~ /SLES 12/ ? undef : '/Created/' });
    # reduce the watch cycle. just for the tests
    TestUtils::test_command({ cmd => "/bin/sed -ri 's/CYCLE_SECS:-60/CYCLE_SECS:-3/g' /opt/omd/versions/default/bin/snmptrapd_mirror_watch" });

    # the phase 1 sites are gone - create fresh ones
    my $site3 = TestUtils::create_test_site('testsnmp1') or TestUtils::bail_out_clean("no further testing without site");
    my $site4 = TestUtils::create_test_site('testsnmp2') or TestUtils::bail_out_clean("no further testing without site");

    # start site3 with a local snmptrapd. find out the listener port
    TestUtils::test_command({ cmd => $omd_bin." config $site3 set SNMPTRAPD on" });
    TestUtils::test_command({ cmd => $omd_bin." start $site3", like => '/Starting snmptrapd\.+OK/' });
    my $site3port = { cmd => $omd_bin." config $site3 show SNMPTRAPD_UDP_PORT", like => '/\d+/' };
    TestUtils::test_command($site3port);
    $site3port = $site3port->{stdout};
    chomp $site3port;

    # start the mirror watcher: it creates /etc/snmp/snmptrapd.conf and
    # starts the mirror within one watch cycle
    TestUtils::test_command({ cmd => "/bin/rm -f /etc/snmp/snmptrapd.conf" });
    TestUtils::test_command({ cmd => "$systemctl start snmptrapd_mirror_watch" });
    TestUtils::test_command({ cmd => "$systemctl status snmptrapd_mirror_watch", like => '/running/' });
    # waitfor patterns are applied with m/$pat/mx (extended mode): literal
    # spaces must be escaped or they are ignored by the regex
    TestUtils::test_command({ cmd => "/bin/grep forward /etc/snmp/snmptrapd.conf", like => '/forward default udp:127\.0\.0\.1:'. $site3port .'/', waitfor => 'forward\ default\ udp:127\.0\.0\.1:'.$site3port });
    # the mirror is up and owns UDP/162
    TestUtils::test_command({ cmd => "$systemctl status snmptrapd_mirror", like => '/running/', waitfor => 'running' });
    TestUtils::test_command({ cmd => '/bin/ps -ef | grep snmptrapd', like => '/snmptrapd\.conf udp:162/' });
    # the helper agrees: the method is the mirror and the section is in sync
    TestUtils::test_command({ cmd => $tt." method", like => '/snmptrapd_mirror/' });
    TestUtils::test_command({ cmd => $tt." check", like => '/section: in sync/' });
    my $mirrorpid = { cmd => "$systemctl show -p MainPID snmptrapd_mirror", like => '/\d+/' };
    TestUtils::test_command($mirrorpid);
    $mirrorpid = $mirrorpid->{stdout};
    chomp $mirrorpid;

    # start site4: the watcher adds its forward line (D4) and reloads the
    # mirror without a delivery gap (same PID after the reload)
    TestUtils::test_command({ cmd => $omd_bin." config $site4 set SNMPTRAPD on" });
    TestUtils::test_command({ cmd => $omd_bin." start $site4", like => '/Starting snmptrapd\.+OK/' });
    my $site4port = { cmd => $omd_bin." config $site4 show SNMPTRAPD_UDP_PORT", like => '/\d+/' };
    TestUtils::test_command($site4port);
    $site4port = $site4port->{stdout};
    chomp $site4port;
    TestUtils::test_command({ cmd => "/bin/grep forward /etc/snmp/snmptrapd.conf", like => '/forward default udp:127\.0\.0\.1:'. $site4port .'/', waitfor => 'forward\ default\ udp:127\.0\.0\.1:'.$site4port });
    TestUtils::test_command({ cmd => "$systemctl status snmptrapd_mirror", like => '/running/' });
    my $mirrorpid2 = { cmd => "$systemctl show -p MainPID snmptrapd_mirror", like => '/\d+/' };
    TestUtils::test_command($mirrorpid2);
    $mirrorpid2 = $mirrorpid2->{stdout};
    chomp $mirrorpid2;
    is($mirrorpid, $mirrorpid2, "mirror reloaded without restart (gap-free)");

    # traps through the mirror: community routing like in the legacy phase
    TestUtils::test_command({ cmd => "$snmptrap -Ln -v 2c -c $site3 127.0.0.1 '' 1.3.6.1.4.1.8072.2.3.0.1 1.3.6.1.4.1.8072.2.3.2.1 i 55555" });
    TestUtils::test_command({ cmd => "$snmptrap -Ln -v 2c -c $site4 127.0.0.1 '' 1.3.6.1.4.1.8072.2.3.0.1 1.3.6.1.4.1.8072.2.3.2.1 i 66666" });
    TestUtils::test_command({ cmd => "$snmptrap -Ln -v 2c -c public 127.0.0.1 '' 1.3.6.1.4.1.8072.2.3.0.1 1.3.6.1.4.1.8072.2.3.2.1 i 77777" });
    TestUtils::test_command({ cmd => "$snmptrap -Ln -v 2c -c gsjcuh 127.0.0.1 '' 1.3.6.1.4.1.8072.2.3.0.1 1.3.6.1.4.1.8072.2.3.2.1 i 88888" });

    TestUtils::wait_for_file("/omd/sites/$site3/var/log/snmp/traps.log");
    TestUtils::wait_for_file("/omd/sites/$site4/var/log/snmp/traps.log");
    TestUtils::test_command({ cmd => "/bin/grep 55555 /omd/sites/$site3/var/log/snmp/traps.log", like => '/____.1.3.6.1.4.1.8072.2.3.2.1 55555/', exit => undef });
    TestUtils::test_command({ cmd => "/bin/grep 55555 /omd/sites/$site4/var/log/snmp/traps.log", unlike => '/____.1.3.6.1.4.1.8072.2.3.2.1 55555/', exit => undef });
    TestUtils::test_command({ cmd => "/bin/grep 66666 /omd/sites/$site3/var/log/snmp/traps.log", unlike => '/____.1.3.6.1.4.1.8072.2.3.2.1 66666/', exit => undef });
    TestUtils::test_command({ cmd => "/bin/grep 66666 /omd/sites/$site4/var/log/snmp/traps.log", like => '/____.1.3.6.1.4.1.8072.2.3.2.1 66666/', exit => undef });
    TestUtils::test_command({ cmd => "/bin/grep 77777 /omd/sites/$site3/var/log/snmp/traps.log", like => '/____.1.3.6.1.4.1.8072.2.3.2.1 77777/', exit => undef });
    TestUtils::test_command({ cmd => "/bin/grep 77777 /omd/sites/$site4/var/log/snmp/traps.log", like => '/____.1.3.6.1.4.1.8072.2.3.2.1 77777/', exit => undef });
    TestUtils::test_command({ cmd => "/bin/grep 88888 /omd/sites/$site3/var/log/snmp/traps.log", unlike => '/____.1.3.6.1.4.1.8072.2.3.2.1 88888/', exit => undef });
    TestUtils::test_command({ cmd => "/bin/grep 88888 /omd/sites/$site4/var/log/snmp/traps.log", unlike => '/____.1.3.6.1.4.1.8072.2.3.2.1 88888/', exit => undef });

    # provenance: the mirror appended the addForwarderInfo marker and the
    # (patched) site logger consumed it - the marker OID must not appear in
    # the site's log, and the summary's sender field is the bare IP
    # (not the 'UDP: [...]' string the receiver sees)
    TestUtils::test_command({ cmd => "/bin/grep 77777 /omd/sites/$site3/var/log/snmp/traps.log", like => '/summary: ____.*____127\.0\.0\.1____/', unlike => '/UDP:/', exit => undef });
    TestUtils::test_command({ cmd => "/bin/grep 77777 /omd/sites/$site4/var/log/snmp/traps.log", like => '/summary: ____.*____127\.0\.0\.1____/', unlike => '/UDP:/', exit => undef });

    # the managed section carries NO authCommunity lines (community policy
    # lives in each site's own snmptrapd.conf) and the mirror runs without
    # a -L destination + with doNotLogTraps 1: the traps above were written
    # to the site trap logs (verified above) but journald must NOT carry
    # one line per trap - the journal would be flooded at production trap
    # volumes. Operational state (the 'NET-SNMP version' startup/reload
    # lines, syslog tag snmptrapd) must still be present there.
    # comment lines are skipped: the template documents the site-side
    # 'authCommunity log,execute,net <community>' pattern in its comments
    TestUtils::test_command({ cmd => "/bin/grep -v '^[[:space:]]*#' /etc/snmp/snmptrapd.conf | /bin/grep authCommunity", unlike => '/authCommunity/', exit => undef });
    TestUtils::test_command({ cmd => "/bin/grep 'disableAuthorization yes' /etc/snmp/snmptrapd.conf", like => '/disableAuthorization yes/' });
    TestUtils::test_command({ cmd => "/bin/grep 'doNotLogTraps 1' /etc/snmp/snmptrapd.conf", like => '/doNotLogTraps 1/' });
    TestUtils::test_command({ cmd => "/bin/grep -v '^[[:space:]]*#' /etc/snmp/snmptrapd.conf | /bin/grep 'log,execute,net'", unlike => '/log,execute,net/', exit => undef });
    # absolute path: test_command runs with the test's cwd prepended to PATH
    # (a bare 'journalctl' would resolve to /root/omd/journalctl - not found)
    my $syslog = "/usr/bin/journalctl -t snmptrapd --since '-10min'";
    TestUtils::test_command({ cmd => $syslog, like => '/NET-SNMP version/', exit => undef });
    TestUtils::test_command({ cmd => $syslog, unlike => '/55555|66666|77777|88888/', exit => undef });
    my $unitjournal = "/usr/bin/journalctl -u snmptrapd_mirror --since '-10min'";
    TestUtils::test_command({ cmd => $unitjournal, unlike => '/55555|66666|77777|88888/', exit => undef });

    # drop site4: the forward line disappears, the mirror keeps running
    TestUtils::test_command({ cmd => $omd_bin." stop $site4" });
    TestUtils::test_command({ cmd => $omd_bin." config $site4 set SNMPTRAPD off" });
    TestUtils::test_command({ cmd => $omd_bin." start $site4", unlike => '/Starting dedicated SNMPTrapd for site.+OK/' });
    TestUtils::test_command({ cmd => "/bin/grep forward /etc/snmp/snmptrapd.conf", unlike => '/forward default udp:127\.0\.0\.1:'. $site4port .'/', waitfor => "!forward\ default\ udp:127\.0\.0\.1:$site4port" });
    TestUtils::test_command({ cmd => "$systemctl status snmptrapd_mirror", like => '/running/' });

    # drop site3 as well: no targets left - the watcher stops the mirror (D2)
    TestUtils::test_command({ cmd => $omd_bin." stop $site3" });
    TestUtils::test_command({ cmd => $omd_bin." config $site3 set SNMPTRAPD off" });
    TestUtils::test_command({ cmd => $omd_bin." start $site3", unlike => '/Starting dedicated SNMPTrapd for site.+OK/' });
    TestUtils::test_command({ cmd => "$systemctl status snmptrapd_mirror", like => '/inactive|exited/', exit => undef, waitfor => 'inactive', maxwait => 90 });

    ##Clean up
    TestUtils::test_command({ cmd => $omd_bin." stop $site3" });
    TestUtils::remove_test_site($site3);
    TestUtils::test_command({ cmd => $omd_bin." stop $site4" });
    TestUtils::remove_test_site($site4);
    #
    TestUtils::test_command({ cmd => "$systemctl stop snmptrapd_mirror_watch" });
    TestUtils::test_command({ cmd => "$systemctl stop snmptrapd_mirror", exit => undef });
    TestUtils::test_command({ cmd => "$systemctl disable snmptrapd_mirror_watch", errlike => $os =~ /SLES 12/ ? undef : '/Removed/' });
    TestUtils::test_command({ cmd => "/bin/rm -f /etc/systemd/system/snmptrapd_mirror_watch.service" });
    TestUtils::test_command({ cmd => "/bin/rm -f /etc/systemd/system/snmptrapd_mirror.service" });
    TestUtils::test_command({ cmd => "$systemctl daemon-reload" });
    TestUtils::test_command({ cmd => "/bin/rm -f /etc/snmp/snmptrapd.conf" });
}

# restore selinux
if($selinux) {
    `setenforce 1 >/dev/null 2>&1`;
    diag("enabled selinux again");
}

done_testing();
