#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use Sys::Hostname;
use Template::Plugin::Date;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
    use FindBin;
    use lib "$FindBin::Bin/lib/lib/perl5";
}

plan( tests => 117 );

##################################################
# get version strings
chomp(my $modgearman_version = qx(grep "^VERSION " packages/mod-gearman2/Makefile | awk '{ print \$3 }'));
chomp(my $libgearman_version = qx(grep "^VERSION " packages/gearmand/Makefile | awk '{ print \$3 }'));
isnt($modgearman_version, '', "got modgearman_version") or BAIL_OUT("need mod-gearman version");
isnt($libgearman_version, '', "got libgearman_version") or BAIL_OUT("need lib-gearman version");;

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();

for my $core (qw/naemon/) {
    my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");
    my $host    = "omd-".$site;
    my $service = "Dummy+Service";

    # make tests more reliable
    TestUtils::test_command({ cmd => "/usr/bin/env sed -i -e 's/^idle-timeout=30/idle-timeout=300/g' /opt/omd/sites/$site/etc/mod-gearman/worker.cfg" });
    TestUtils::file_contains({file => "/opt/omd/sites/$site/etc/mod-gearman/worker.cfg", like => ['/^idle\-timeout=300/mx'] });

    # increase worker loglevel
    TestUtils::test_command({ cmd => "/usr/bin/env sed -i -e 's/^debug=0/debug=2/g' /opt/omd/sites/$site/etc/mod-gearman/worker.cfg" });
    TestUtils::file_contains({file => "/opt/omd/sites/$site/etc/mod-gearman/worker.cfg", like => ['/^debug=2/mx'] });

    # create test host/service
    TestUtils::prepare_obj_config('t/data/omd/testconf1', '/omd/sites/'.$site.'/etc/'.$core.'/conf.d', $site);

    ##################################################
    # decrease status update interval
    TestUtils::test_command({ cmd => "/usr/bin/env sed -i -e 's/^status_update_interval=30/status_update_interval=3/g' /opt/omd/sites/$site/etc/$core/$core.d/tuning.cfg" });

    ##################################################
    # prepare site
    my $tpd  = Template::Plugin::Date->new();
    my $now  = $tpd->format(time(), '%Y-%m-%d %H:%M:%S');
    $now     =~ s/\ /+/gmx;
    $now     =~ s/:/%3A/gmx;

    my $preps = [
      { cmd => $omd_bin." config $site set CORE $core" },
      { cmd => $omd_bin." config $site set MOD_GEARMAN on" },
      { cmd => "/usr/bin/test -s /omd/sites/$site/etc/mod-gearman/secret.key", "exit" => 0 },
      { cmd => "/bin/su - $site -c 'rm -f var/*/retention.dat'", like => '/^$/' },
      { cmd => $omd_bin." start $site", like => [ '/gearmand\.\.\.OK/', '/gearman_worker\.\.\.OK/'], sleep => 1 },
      { cmd => $omd_bin." status $site", like => [ '/gearmand:\s+running/', '/gearman_worker:\s*running/'] },
      { cmd => "/bin/su - $site -c './lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/thruk/cgi-bin/cmd.cgi -e 200 -P \"cmd_typ=7&cmd_mod=2&host=omd-$site&service=Dummy+Service&start_time=$now&force_check=on&btnSubmit=Commit\" -r \"successfully submitted\"'", like => '/HTTP OK:/' },
      { cmd => "/bin/su - $site -c './lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/thruk/cgi-bin/cmd.cgi -e 200 -P \"cmd_typ=7&cmd_mod=2&host=omd-$site&service=perl+test&start_time=$now&force_check=on&btnSubmit=Commit\" -r \"successfully submitted\"'", like => '/HTTP OK:/' },
      { cmd => $omd_bin." status $site", like => [
                                                '/apache:\s*running/',
                                                '/rrdcached:\s*running/',
                                                '/gearman_worker:\s*running/',
                                                "/$core:\\s*running/",
                                                '/Overall state:\s*running/',
                                               ]
      },
    ];
    for my $test (@{$preps}) {
        TestUtils::test_command($test) or TestUtils::bail_out_clean("no further testing without proper preparation");
    }

    ##################################################
    # execute some checks
    my $tests = [
      { cmd => "/bin/grep 'Event broker module.*mod_gearman2.o.*initialized successfully' /omd/sites/$site/var/$core/$core.log", like => '/successfully/' },
      { cmd => "/bin/grep 'mod_gearman: initialized version ".$modgearman_version." \(libgearman ".$libgearman_version."\)' /omd/sites/$site/var/$core/$core.log", like => '/initialized/' },
      { cmd => "/bin/su - $site -c 'bin/send_gearman --server=localhost:4730 --keyfile=etc/mod-gearman/secret.key --host=$host --message=test'" },
      { cmd => "/bin/su - $site -c 'bin/send_gearman --server=localhost:4730 --keyfile=etc/mod-gearman/secret.key --host=$host --service=$service --message=test'" },
      { cmd => "/bin/grep -i 'mod_gearman: ERROR' /omd/sites/$site/var/$core/$core.log", 'exit' => 1, like => '/^\s*$/' },
      { cmd => "/bin/grep -i 'mod_gearman: WARN' /omd/sites/$site/var/$core/$core.log", 'exit' => 1, like => '/^\s*$/' },
      { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_gearman -H localhost:4730'", like => '/check_gearman OK/' },
      { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_gearman -H localhost:4730 -q host'", like => '/check_gearman OK/' },
    ];
    for my $test (@{$tests}) {
        TestUtils::test_command($test);
    }

    #--- wait for all services being checked
    TestUtils::wait_for_content({
        url => "http://localhost/$site/thruk/cgi-bin/status.cgi?host=$host&servicestatustypes=1&hoststatustypes=15",
        auth    => "OMD Monitoring Site $site:omdadmin:omd",
        like    => [ "0 Matching Service" ],
        }
    );

    # verify the jobs done
    my $test = { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_gearman -H localhost:4730 -q worker_".hostname." -t 10 -s check'", like => [ '/check_gearman OK/' ] };
    TestUtils::test_command($test);
    chomp($test->{'stdout'});
    unlike($test->{'stdout'}, qr/jobs=0c/, "worker has jobs done: ".$test->{'stdout'});
    my $worker = 0;
    if( $test->{'stdout'} =~ m/worker=(\d+)/ ) { $worker = $1 }
    ok($worker >= 3, "worker number >= 3: $worker") or diag($test->{'stdout'});

    TestUtils::file_contains({file => "/opt/omd/sites/$site/var/log/gearman/worker.log", like => ['/Using Embedded Perl interpreter for: .*check_webinject/', '/Embedded Perl successfully compiled/', '/^output=.*find\ any\ test/mx'], unlike => ['/\[ERROR\]/'] });

    TestUtils::test_command({
        cmd => $omd_bin." status $site", like => [
                                                '/apache:\s*running/',
                                                '/rrdcached:\s*running/',
                                                '/gearman_worker:\s*running/',
                                                "/$core:\\s*running/",
                                                '/Overall state:\s*running/',
                                         ]
    });
 
    ##################################################
    # cleanup test site
    TestUtils::test_command({ cmd => $omd_bin." stop $site" });
    TestUtils::remove_test_site($site);
}

