#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use Data::Dumper;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
    use FindBin;
    use lib "$FindBin::Bin/lib/lib/perl5";
}

plan( tests => 2082 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");
my $auth    = 'OMD Monitoring Site '.$site.':omdadmin:omd';
my $host    = "omd-".$site;
my $service = "Dummy+Service";

# create test host/service
TestUtils::prepare_obj_config('t/data/omd/testconf1', '/omd/sites/'.$site.'/etc/nagios/conf.d', $site);

# decrease pnp interval
TestUtils::test_command({ cmd => "/usr/bin/env sed -i -e 's/^perfdata_file_processing_interval = 15/perfdata_file_processing_interval = 2/g' -e 's/^sleep_time = 15/sleep_time = 2/g' /opt/omd/sites/$site/etc/pnp4nagios/npcd.cfg" });

# set thruk as default
TestUtils::test_command({ cmd => $omd_bin." config $site set DEFAULT_GUI thruk" });
TestUtils::test_command({ cmd => $omd_bin." start $site" });

##################################################
# define some checks
my $tests = [
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 60 -H localhost -a omdadmin:omd -u /$site/thruk/side.html -e 200'", like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 20 -H localhost -u /$site/thruk -e 401'",                    like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 60 -H localhost -a omdadmin:omd -u /$site/thruk -e 301'",    like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 60 -H localhost -a omdadmin:omd -u /$site/thruk/ -e 200'",   like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 20 -H localhost -a omdadmin:omd -u \"/$site/thruk/cgi-bin/status.cgi?hostgroup=all&style=hostdetail\" -e 200 -r \"Host Status Details For All Host Groups\"'", like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 20 -H localhost -a omdadmin:omd -u \"/$site/thruk/cgi-bin/tac.cgi\" -e 200 -r \"Logged in as <i>omdadmin<\/i>\"'", like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'bin/thruk -l'", like => "/$site/" },
  { cmd => "/bin/su - $site -c 'bin/thruk -l --local'", like => "/$site/" },
];
my $urls = [
# static html pages
  { url => "",                       like => '/<title>Thruk<\/title>/' },
  { url => "/thruk/index.html",      like => '/<title>Thruk<\/title>/' },
  { url => "/thruk/docs/index.html", like => '/<title>Documentation<\/title>/' },
  { url => "/thruk/main.html",       like => '/<title>Thruk Monitoring Webinterface<\/title>/' },
  { url => "/thruk/side.html",       like => '/<title>Thruk<\/title>/' },

# availability
  { url => '/thruk/cgi-bin/avail.cgi', 'like' => '/Availability Report/' },
  { url => '/thruk/cgi-bin/avail.cgi?host='.$host.'&timeperiod=last7days&smon=1&sday=13&syear=2010&shour=0&smin=0&ssec=0&emon=1&eday=14&eyear=2010&ehour=24&emin=0&esec=0&rpttimeperiod=&assumeinitialstates=yes&assumestateretention=yes&assumestatesduringnotrunning=yes&includesoftstates=no&initialassumedservicestate=0&backtrack=4', 'like' => '/Availability Report/' },

# extinfo
  { url => '/thruk/cgi-bin/extinfo.cgi?type=1&host='.$host },
  { url => '/thruk/cgi-bin/extinfo.cgi?type=2&host='.$host.'&service='.$service },

# config
  { url => '/thruk/cgi-bin/config.cgi',               'like' => '/Configuration/' },
  { url => '/thruk/cgi-bin/config.cgi?type=hosts',    'like' => '/Configuration/' },
  { url => '/thruk/cgi-bin/config.cgi?type=services', 'like' => '/Configuration/' },

# history
  { url => '/thruk/cgi-bin/history.cgi',                                  like => '/Alert History/' },
  { url => '/thruk/cgi-bin/history.cgi?host=all',                         like => '/Alert History/' },
  { url => '/thruk/cgi-bin/history.cgi?host='.$host,                      like => '/Alert History/' },
  { url => '/thruk/cgi-bin/history.cgi?host='.$host.'&service='.$service, like => '/Alert History/' },

# notifications
  { url => '/thruk/cgi-bin/notifications.cgi', like => '/All Hosts and Services/' },

# outages
  { url => '/thruk/cgi-bin/outages.cgi', like => '/Network Outages/' },

# showlog
  { url => '/thruk/cgi-bin/showlog.cgi', like => '/Event Log/' },

# status
  { url => '/thruk/cgi-bin/status.cgi',             like => '/Current Network Status/' },
  { url => '/thruk/cgi-bin/status.cgi?host='.$host, like => '/Current Network Status/' },

# summary
  { url => '/thruk/cgi-bin/summary.cgi', like => '/Alert Summary Report/' },

# tac
  { url => '/thruk/cgi-bin/tac.cgi', like => '/Tactical Monitoring Overview/' },

# trends
  { url => '/thruk/cgi-bin/trends.cgi?host='.$host.'&t1=1264820912&t2=1265425712&includesoftstates=no&assumestateretention=yes&assumeinitialstates=yes&assumestatesduringnotrunning=yes&initialassumedhoststate=0&backtrack=4', 'like'  => '/Host and Service State Trends/' },
  { url => '/thruk/cgi-bin/trends.cgi?host='.$host.'&service='.$service.'&t1=1264820912&t2=1265425712&includesoftstates=no&assumestateretention=yes&assumeinitialstates=yes&assumestatesduringnotrunning=yes&initialassumedservicestate=0&backtrack=4', 'like' => '/Host and Service State Trends/' },

# statusmap
  { url => '/thruk/cgi-bin/statusmap.cgi?host=all', like => '/Network Map For All Hosts/' },

# minemap
  { url => '/thruk/cgi-bin/minemap.cgi', like => '/Mine Map/' },

# conf tool
  { url => '/thruk/cgi-bin/conf.cgi', like => '/Config Tool/' },
  { url => '/thruk/cgi-bin/conf.cgi?sub=thruk', like => [ '/Config Tool/', '/title_prefix/', '/use_wait_feature/'] },
  { url => '/thruk/cgi-bin/conf.cgi?sub=cgi', like => [ '/Config Tool/', '/show_context_help/', '/use_pending_states/' ] },
  { url => '/thruk/cgi-bin/conf.cgi?sub=users', like => [ '/Config Tool/', '/select user to change/' ] },
  { url => '/thruk/cgi-bin/conf.cgi?sub=users&action=change&data.username=omdadmin', like => [ '/Config Tool/', '/remove password/', '/authorized_for_all_services/' ] },
  { url => '/thruk/cgi-bin/conf.cgi?sub=objects', like => [ '/Config Tool/', '/select host to change/' ] },
  { url => '/thruk/cgi-bin/conf.cgi?sub=objects&apply=yes', like => [ '/Config Tool/', '/There are no pending changes to commit/' ] },
  { url => '/thruk/cgi-bin/conf.cgi?sub=objects&type=host&data.name=generic-host', like => [ '/Config Tool/', '/Template:\s+generic\-host/', '/templates.cfg/' ], skip_html_links => 1 },
  { url => '/thruk/cgi-bin/conf.cgi?sub=objects&action=browser', like => [ '/Config Tool/', '/commands.cfg/' ] },
];

# complete the url
for my $url ( @{$urls} ) {
    $url->{'url'} = "http://localhost/".$site.$url->{'url'};
    $url->{'auth'}   = $auth;
    $url->{'unlike'} = [ '/internal server error/', '/"\/thruk\//', '/\'\/thruk\//' ];
}

for my $core (qw/nagios shinken icinga/) {
    ##################################################
    # run our tests
    TestUtils::test_command({ cmd => $omd_bin." stop $site" });
    TestUtils::test_command({ cmd => $omd_bin." config $site set CORE $core" });
    TestUtils::test_command({ cmd => $omd_bin." start $site" })   or TestUtils::bail_out_clean("No need to test Thruk without proper startup");
    TestUtils::wait_for_file("/omd/sites/$site/tmp/run/live", 60) or TestUtils::bail_out_clean("No need to test Thruk without livestatus connection");
    unlink('var/thruk/obj_retention.dat');

    TestUtils::test_command({ cmd => "/bin/su - $site -c './lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/nagios/cgi-bin/cmd.cgi -e 200 -P \"cmd_typ=7&cmd_mod=2&host=omd-$site&service=Dummy+Service&start_time=2010-11-06+09%3A46%3A02&force_check=on&btnSubmit=Commit\" -r \"Your command request was successfully submitted\"'", like => '/HTTP OK:/' });
    TestUtils::wait_for_file("/omd/sites/$site/var/pnp4nagios/perfdata/omd-$site/Dummy_Service_omd-dummy.rrd", 60) or TestUtils::bail_out_clean("No need to test Thruk without working pnp");;

    for my $test (@{$tests}) {
        TestUtils::test_command($test);
    }
    ##################################################
    # and request some pages
    for my $url ( @{$urls} ) {
        TestUtils::test_url($url);
    }

    ##################################################
    # switch webserver to shared mode
    TestUtils::test_command({ cmd => $omd_bin." stop $site" });
    TestUtils::test_command({ cmd => $omd_bin." config $site set APACHE_MODE shared" });
    TestUtils::test_command({ cmd => TestUtils::config('APACHE_INIT')." restart" });
    TestUtils::test_command({ cmd => $omd_bin." start $site" });

    ##################################################
    # then run tests again
    for my $test (@{$tests}) {
        TestUtils::test_command($test);
    }
    ##################################################
    # and request some pages
    for my $url ( @{$urls} ) {
        TestUtils::test_url($url);
    }

    my $log = "/omd/sites/$site/var/log/thruk.log";
    is(-f $log, 1, "log exists");
    is(-s $log, 0, "log is empty") or diag(Dumper(`cat $log`));
}

##################################################
# cleanup test site
TestUtils::test_command({ cmd => TestUtils::config('APACHE_INIT')." restart" });
TestUtils::remove_test_site($site);
