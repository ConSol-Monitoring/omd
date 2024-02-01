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

plan( tests => 256 );

##################################################
# get version strings
chomp(my $modgearman_version = qx(grep "^VERSION " packages/mod-gearman/Makefile | awk '{ print \$3 }'));
chomp(my $libgearman_version = qx(grep "^VERSION " packages/gearmand/Makefile | awk '{ print \$3 }'));
isnt($modgearman_version, '', "got modgearman_version") or BAIL_OUT("need mod-gearman version");
isnt($libgearman_version, '', "got libgearman_version") or BAIL_OUT("need lib-gearman version");;

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();

{
    my $core     = 'naemon';
    my $site     = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");
    my $host     = "omd-".$site;
    my $service  = "Dummy Service";
    my $module   = 'mod_gearman_naemon.o';

    `install -m 755 t/lib/check_locale.py /omd/sites/$site/local/lib/monitoring-plugins/`;
    `install -m 644 t/data/naemon.cfg /omd/sites/$site/etc/naemon/conf.d/example-naemon.cfg`;

    # make tests more reliable
    TestUtils::test_command({ cmd => "/usr/bin/env sed -i -e 's/^idle-timeout=30/idle-timeout=300/g' /opt/omd/sites/$site/etc/mod-gearman/worker.cfg" });
    TestUtils::file_contains({file => "/opt/omd/sites/$site/etc/mod-gearman/worker.cfg", like => ['/^idle\-timeout=300/mx'] });

    # increase worker loglevel
    TestUtils::test_command({ cmd => "/usr/bin/env sed -i -e 's/^debug=0/debug=2/g' /opt/omd/sites/$site/etc/mod-gearman/worker.cfg" });
    TestUtils::file_contains({file => "/opt/omd/sites/$site/etc/mod-gearman/worker.cfg", like => ['/^debug=2/mx'] });

    # create test host/service
    TestUtils::prepare_obj_config('t/data/omd/testconf1', '/omd/sites/'.$site.'/etc/'.$core.'/conf.d', $site);
    TestUtils::test_command({ cmd => "/bin/cp t/data/mod-gearman/multi.cfg /omd/sites/$site/etc/$core/conf.d/multi.cfg" });
    TestUtils::test_command({ cmd => "/bin/cp t/data/mod-gearman/internal.cfg /omd/sites/$site/etc/$core/conf.d/internal.cfg" });
    TestUtils::test_command({ cmd => "/bin/su - $site -c 'echo \"p test\" > etc/test.cfg'", like => '/^\s*$/' });

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
      { cmd => "/bin/su - $site -c 'cp share/doc/naemon/example.cfg etc/naemon/conf.d/'", like => '/^$/' },
      { cmd => $omd_bin." config $site set CORE $core" },
      { cmd => $omd_bin." config $site set MOD_GEARMAN on" },
      { cmd => "/usr/bin/test -s /omd/sites/$site/etc/mod-gearman/secret.key", "exit" => 0 },
      { cmd => "/bin/su - $site -c 'rm -f var/*/retention.dat'", like => '/^$/' },
      { cmd => $omd_bin." start $site", like => [ '/gearmand\.\.\.OK/', '/gearman_worker\.\.\.OK/'], sleep => 1 },
      { cmd => $omd_bin." status $site", like => [ '/gearmand:\s+running/', '/gearman_worker:\s*running/'] },
      { cmd => "/bin/su - $site -c './lib/monitoring-plugins/check_http -H localhost -a omdadmin:omd -u /$site/thruk/cgi-bin/cmd.cgi -e 200 -P \"cmd_typ=7&cmd_mod=2&host=omd-$site&service=Dummy+Service&start_time=$now&force_check=on&btnSubmit=Commit\" -r \"successfully submitted\"'", like => '/HTTP OK:/' },
      { cmd => "/bin/su - $site -c './lib/monitoring-plugins/check_http -H localhost -a omdadmin:omd -u /$site/thruk/cgi-bin/cmd.cgi -e 200 -P \"cmd_typ=7&cmd_mod=2&host=omd-$site&service=perl+test&start_time=$now&force_check=on&btnSubmit=Commit\" -r \"successfully submitted\"'", like => '/HTTP OK:/' },
      { cmd => "/bin/su - $site -c './lib/monitoring-plugins/check_http -H localhost -a omdadmin:omd -u /$site/thruk/cgi-bin/cmd.cgi -e 200 -P \"cmd_typ=7&cmd_mod=2&host=omd-$site&service=multiline&start_time=$now&force_check=on&btnSubmit=Commit\" -r \"successfully submitted\"'", like => '/HTTP OK:/' },
      { cmd => $omd_bin." status $site", like => [
                                                '/apache:\s*running/',
                                                '/rrdcached:\s*running/',
                                                '/gearman_worker:\s*running/',
                                                "/$core:\\s*running/",
                                                '/Overall state:\s*running/',
                                               ]
      },
      { cmd => "/bin/su - $site -c 'echo \"COMMAND [".time()."] SCHEDULE_FORCED_SVC_CHECK;localhost;locale;".time()."\" | lq'", like => '/^\s*$/' },
      { cmd => "/bin/su - $site -c 'echo \"COMMAND [".time()."] SCHEDULE_FORCED_HOST_CHECK;$host;".time()."\" | lq'", like => '/^\s*$/' },
      { cmd => "/bin/su - $site -c 'echo -e \"".'GET hosts\nFilter: name = '.$host.'\nColumns: plugin_output\n'."\" | lq'", waitfor => 'Please\ remove\ this\ host\ later' },
      { cmd => "/bin/su - $site -c 'echo \"COMMAND [".time()."] SCHEDULE_FORCED_SVC_CHECK;$host;internal_dummy;".time()."\" | lq'", like => '/^\s*$/' },
      { cmd => "/bin/su - $site -c 'echo \"COMMAND [".time()."] SCHEDULE_FORCED_SVC_CHECK;$host;internal_dummy2;".time()."\" | lq'", like => '/^\s*$/' },
      { cmd => "/bin/su - $site -c 'echo \"COMMAND [".time()."] SCHEDULE_FORCED_SVC_CHECK;$host;internal_dummy3;".time()."\" | lq'", like => '/^\s*$/' },
      { cmd => "/bin/su - $site -c 'echo \"COMMAND [".time()."] SCHEDULE_FORCED_SVC_CHECK;$host;internal_dummy4;".time()."\" | lq'", like => '/^\s*$/' },
      { cmd => "/bin/su - $site -c 'echo \"COMMAND [".time()."] SCHEDULE_FORCED_SVC_CHECK;$host;internal_nsc_web;".time()."\" | lq'", like => '/^\s*$/' },
      { cmd => "/bin/su - $site -c 'echo \"COMMAND [".time()."] SCHEDULE_FORCED_SVC_CHECK;$host;internal_nsc_web2;".time()."\" | lq'", like => '/^\s*$/' },
      { cmd => "/bin/su - $site -c 'sleep 2'", like => '/^\s*$/' },
      { cmd => "/bin/su - $site -c 'echo \"GET services\nFilter: host_name = localhost\nFilter: description = locale\nColumns: state plugin_output long_plugin_output\n\n\" | lq'", like => '/^0;LANG=/' },
    ];
    for my $test (@{$preps}) {
        TestUtils::test_command($test);
    }

    ##################################################
    # execute some checks
    my $tests = [
      { cmd => "/bin/grep 'Event broker module.*$module.*initialized successfully' /omd/sites/$site/var/$core/$core.log", like => '/successfully/' },
      { cmd => "/bin/grep 'mod_gearman: initialized version ".$modgearman_version." \(libgearman ".$libgearman_version."\)' /omd/sites/$site/var/$core/$core.log", like => '/initialized/' },
      { cmd => "/bin/su - $site -c 'bin/send_gearman --server=127.0.0.1:4730 --keyfile=etc/mod-gearman/secret.key --host=$host --message=test'" },
      { cmd => "/bin/su - $site -c 'bin/send_gearman --server=127.0.0.1:4730 --keyfile=etc/mod-gearman/secret.key --host=$host --service=\"$service\" --message=test'" },
      { cmd => "/bin/grep -i 'mod_gearman: ERROR' /omd/sites/$site/var/$core/$core.log", 'exit' => 1, like => '/^\s*$/' },
      { cmd => "/bin/grep -i 'mod_gearman: WARN' /omd/sites/$site/var/$core/$core.log", 'exit' => 1, like => '/^\s*$/' },
      { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_gearman -H 127.0.0.1:4730'", like => '/check_gearman OK/' },
      { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_gearman -H 127.0.0.1:4730 -q host'", like => '/check_gearman OK/' },
    ];
    for my $test (@{$tests}) {
        TestUtils::test_command($test);
    }

    #--- wait for all services being checked
    TestUtils::wait_for_content({
        url  => "http://localhost/$site/thruk/cgi-bin/status.cgi?host=$host&servicestatustypes=1&hoststatustypes=15",
        auth => "OMD Monitoring Site $site:omdadmin:omd",
        like => [ "0 Items Displayed" ],
        }
    );

    # verify the jobs done
    my $test = { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_gearman -H 127.0.0.1:4730 -q worker_".hostname." -t 10 -s check'", like => [ '/check_gearman OK/' ] };
    TestUtils::test_command($test);
    chomp($test->{'stdout'});
    unlike($test->{'stdout'}, qr/jobs=0c/, "worker has jobs done: ".$test->{'stdout'});
    my $worker = 0;
    if( $test->{'stdout'} =~ m/worker=(\d+)/ ) { $worker = $1 }
    ok($worker >= 3, "worker number >= 3: $worker") or diag($test->{'stdout'});

    TestUtils::file_contains({
        file => "/opt/omd/sites/$site/var/log/gearman/worker.log", 
        like => [
            '/^output=.*find\ any\ test/mx',
        ],
        unlike => ['/\[Error\]/'],
    });

    TestUtils::test_command({
        cmd => $omd_bin." status $site", like => [
                                                '/apache:\s*running/',
                                                '/rrdcached:\s*running/',
                                                '/gearman_worker:\s*running/',
                                                "/$core:\\s*running/",
                                                '/Overall state:\s*running/',
                                         ]
    });

    # test check_source
    TestUtils::test_command({ cmd => "/bin/su - $site -c 'echo -e \"".'GET hosts\nColumns: name check_source\n'."\" | lq'", waitfor => 'Mod-Gearman\ Worker' });

    # test host notifications
    TestUtils::test_command({ cmd => "/bin/su - $site -c 'echo \"COMMAND [".time()."] SEND_CUSTOM_HOST_NOTIFICATION;$host;2;omdadmin;test hst notification\" | lq'", like => '/^\s*$/' });
    TestUtils::test_command({ cmd => "/bin/su - $site -c 'grep NOTIFICATION: var/$core/$core.log'", waitfor => 'HOST\ NOTIFICATION:' });
    TestUtils::file_contains({file => "/opt/omd/sites/$site/var/$core/$core.log", like => ['/HOST NOTIFICATION:.*;CUSTOM.*test hst notification/', '/EXTERNAL COMMAND: SEND_CUSTOM_HOST_NOTIFICATION/'], unlike => ['/SIGSEGV/'] });

    # test service notifications
    TestUtils::test_command({ cmd => "/bin/su - $site -c 'echo \"COMMAND [".time()."] SEND_CUSTOM_SVC_NOTIFICATION;$host;$service;2;omdadmin;test svc notification\" | lq'", like => '/^\s*$/' });
    TestUtils::test_command({ cmd => "/bin/su - $site -c 'grep NOTIFICATION: var/$core/$core.log'", waitfor => 'SERVICE\ NOTIFICATION:' });
    TestUtils::file_contains({file => "/opt/omd/sites/$site/var/$core/$core.log", like => ['/SERVICE NOTIFICATION:.*;CUSTOM.*test svc notification/', '/EXTERNAL COMMAND: SEND_CUSTOM_SVC_NOTIFICATION/'], unlike => ['/SIGSEGV/'] });
 
    TestUtils::test_command({ cmd => "/bin/su - $site -c 'echo -e \"".'GET services\nFilter: description = multiline\nColumns: plugin_output long_plugin_output\n'."\" | lq'", like => '/^OK - firstline;secondline\\\nthirdline\\\nCONFIG_CORE=\''.$core.'\'/' });
    TestUtils::test_command({ cmd => "/bin/su - $site -c 'echo -e \"".'GET services\nFilter: description = multiline\nColumns: perf_data\n'."\" | lq'", like => '/^perf=1c$/' });

    ##################################################
    # test internal checks
    TestUtils::test_command({ cmd => "/bin/su - $site -c 'echo -e \"".'GET services\nFilter: description = internal_dummy\nColumns: state plugin_output\n'."\" | lq'", like => '/^0;OK: Please remove this host later$/' });
    TestUtils::test_command({ cmd => "/bin/su - $site -c 'echo -e \"".'GET services\nFilter: description = internal_dummy2\nColumns: state plugin_output\n'."\" | lq'", like => '/^0;OK: Please remove this host later$/' });
    TestUtils::test_command({ cmd => "/bin/su - $site -c 'echo -e \"".'GET services\nFilter: description = internal_dummy3\nColumns: state plugin_output\n'."\" | lq'", like => '/^1;WARNING: this is warning$/' });
    TestUtils::test_command({ cmd => "/bin/su - $site -c 'echo -e \"".'GET services\nFilter: description = internal_dummy4\nColumns: state plugin_output\n'."\" | lq'", like => '/^2;CRITICAL: critical$/' });
    TestUtils::test_command({ cmd => "/bin/su - $site -c 'echo -e \"".'GET services\nFilter: description = internal_nsc_web\nColumns: state plugin_output\n'."\" | lq'", like => '/^0;OK$/' });
    TestUtils::test_command({ cmd => "/bin/su - $site -c 'echo -e \"".'GET services\nFilter: description = internal_nsc_web2\nColumns: state plugin_output\n'."\" | lq'", like => '/^0;OK$/' });

    ##################################################
    # test sqlite retention
    TestUtils::test_command({ cmd => "/bin/su - $site -c '$omd_bin stop gearmand'", like => '/OK/' });
    TestUtils::test_command({ cmd => "/bin/su - $site -c 'test -f var/gearmand.db'", like => '/^$/' });

    ##################################################
    # starting without gearmand
    TestUtils::test_command({ cmd => "/bin/su - $site -c '$omd_bin restart gearman_worker'", like => '/OK/' });
    TestUtils::test_command({ cmd => $omd_bin." status $site", like => [ '/gearman_worker:\s*running/' ], exit => 2 });

    ##################################################
    # cleanup test site
    TestUtils::test_command({ cmd => $omd_bin." stop $site" });
    TestUtils::remove_test_site($site);
};

