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

plan( tests => 2853 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");
my $auth    = 'OMD Monitoring Site '.$site.':omdadmin:omd';
my $host    = "omd-".$site;
my $service = "Dummy+Service";
my $servicep= "Dummy Service";

# create test host/service
TestUtils::prepare_obj_config('t/data/omd/testconf1', '/omd/sites/'.$site.'/etc/nagios/conf.d', $site);

# decrease pnp interval
TestUtils::test_command({ cmd => "/usr/bin/env sed -i -e 's/^perfdata_file_processing_interval = 15/perfdata_file_processing_interval = 2/g' -e 's/^sleep_time = 15/sleep_time = 2/g' /opt/omd/sites/$site/etc/pnp4nagios/npcd.cfg" });

# set thruk as default
TestUtils::test_command({ cmd => $omd_bin." config $site set DEFAULT_GUI thruk" });
TestUtils::test_command({ cmd => $omd_bin." start $site" });

# set token for post requests
push @INC, '/omd/sites/'.$site.'/share/thruk/lib';
use_ok('Thruk::Utils::Cache');
use_ok('Thruk::Config');
set_test_user_token();


my $reports = [
    {
        'name'                  => 'Host',
        'template'              => 'sla_host.tt',
        'params.sla'            => 95,
        'params.timeperiod'     => 'last12months',
        'params.host'           => $host,
        'params.breakdown'      => 'months',
        'params.unavailable'    => [ 'down', 'unreachable' ],
        'params.graph_min_sla'  => 90,
        'params.decimals'       => 2,
        'send_type_1'           => 'month',
        'send_day_1'            => 1,
        'week_day_1'            => '',
        'send_hour_1'           => 0,
        'send_minute_1'         => 0,
    },
];

##################################################
# define some checks
my $tests = [
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 60 -H localhost -a omdadmin:omd -u /$site/thruk/side.html -e 200'", like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 20 -H localhost -u /$site/thruk -e 401'",                    like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 60 -H localhost -a omdadmin:omd -u /$site/thruk -e 301'",    like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 60 -H localhost -a omdadmin:omd -u /$site/thruk/ -e 200'",   like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 20 -H localhost -a omdadmin:omd -u \"/$site/thruk/cgi-bin/status.cgi?hostgroup=all&style=hostdetail\" -e 200 -r \"Host Status Details For All Host Groups\"'", like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 20 -H localhost -a omdadmin:omd -u \"/$site/thruk/cgi-bin/tac.cgi\" -e 200 -r \"Logged in as <i>omdadmin<\/i>\"'", like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c './bin/thruk -l'", like => "/$site/" },
  { cmd => "/bin/su - $site -c './bin/thruk -l --local'", like => "/$site/" },
  { cmd => "/bin/su - $site -c './bin/naglint ./etc/nagios/conf.d/commands.cfg'", like => "/check_local_load/" },
];

my $own_tests = [
  { cmd => "/bin/su - $site -c './etc/init.d/thruk restart'", like => '/\([\d\ ]+\)\ OK/' },
];
my $shared_tests = [
  { cmd => "/bin/su - $site -c './etc/init.d/thruk restart'", like => '/only available for apaches/', exit => 1 },
];

for my $report (@{$reports}) {
    my $args = [];
    for my $key (keys %{$report}) {
        for my $val (ref $report->{$key} eq 'ARRAY' ? @{$report->{$key}} : $report->{$key}) {
            push @{$args}, $key.'='.$val;
        }
    }
    push @{$tests}, (
      { cmd => "/bin/su - $site -c './bin/thruk -A omdadmin \"/thruk/cgi-bin/reports2.cgi?action=save&report=9999&".join('&', @{$args})."\"'",
               like => "/OK - report updated/" },
      { cmd => "/bin/su - $site -c 'omd reload crontab'", like => [ '/OK/' ] },
      { cmd => "/bin/su - $site -c '/usr/bin/crontab -l | grep -i thruk | grep -v cron.d'", like => [ '/9999/' ] },
      { cmd => "/bin/su - $site -c './bin/thruk -a report=9999 --local'", like => [ '/%PDF\-1\.4/', '/%%EOF/' ] },
      { cmd => "/bin/su - $site -c './bin/thruk -A omdadmin \"/thruk/cgi-bin/reports2.cgi?action=remove&report=9999\"'", like => '/OK - report removed/' },
    );
}


my $urls = [
# static html pages
  { url => "/thruk/side.html",       like => '/<title>Thruk<\/title>/' },
  { url => "",                       like => '/<title>Thruk<\/title>/' },
  { url => "/thruk/index.html",      like => '/<title>Thruk<\/title>/' },
  { url => "/thruk/startup.html",    like => '/<title>Thruk Monitoring Webinterface<\/title>/' },
  { url => "/thruk/docs/index.html", like => '/<title>Documentation<\/title>/' },
  { url => "/thruk/main.html",       like => '/<title>Thruk Monitoring Webinterface<\/title>/' },

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
  { url => '/thruk/cgi-bin/statusmap.cgi?host=all', like => '/Network Map/' },

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

# reporting
  { url => '/thruk/cgi-bin/reports2.cgi', like => '/Reporting/' },
  { url => '/thruk/cgi-bin/reports2.cgi', post => { 'action' => 'save', 'report' => '9999', 'name' => 'Service SLA Report for '.$host.' - '.$servicep, 'template' => 'sla_service.tt', 'params.sla' => 95, 'params.timeperiod' => 'last12months', 'params.host' => $host, 'params.service' => $servicep, 'params.breakdown' => 'months', 'params.unavailable' => ['critical', 'unknown' ], 'params.decimals' => 2, 'params.graph_min_sla' => 90 }, like => '/success_message/' },
  { url => '/thruk/cgi-bin/reports2.cgi?report=9999&action=update' },
  { url => '/thruk/cgi-bin/reports2.cgi', waitfor => 'reports2.cgi\?report=9999\&amp;refresh=0' },
  { url => '/thruk/cgi-bin/reports2.cgi?report=9999', like => [ '/%PDF-1.4/', '/%%EOF/' ] },
  { url => '/thruk/cgi-bin/reports2.cgi', post => { 'action' => 'remove', 'report' => 9999 }, like => '/report removed/' },

# recurring downtimes
  { url => '/thruk/cgi-bin/extinfo.cgi', post => { 'type' => 6, 'recurring' => 'save', 'target' => 'host', 'host' => $host, 'comment' => 'automatic downtime', 'send_type_1' => 'month', 'send_day_1' => 1, 'week_day_1' => '', 'send_hour_1' => 0, 'send_minute_1' => 0, 'duration' => 120, 'childoptions' => 0, 'nr' => 999 }, like => '/recurring downtime saved/' },
  { url => '/thruk/cgi-bin/extinfo.cgi', post => { 'type' => 6, 'target' => 'host', 'recurring' => 'remove', 'nr' => 999, 'host' => $host }, like => '/recurring downtime removed/' },

# usercontent examples
  { url => '/thruk/usercontent/backgrounds/world.png', like => '/PNG/' },
];

my $own_urls = [
# business process
  { url => '/thruk/cgi-bin/bp.cgi?action=new&bp_label=New Test Business Process', like => '/New Test Business Process/', skip_link_check => ['.cgi'] },
  { url => '/thruk/cgi-bin/bp.cgi', post => { 'action' => 'commit', 'bp' => 1 }, like => '/New Test Business Process/', skip_link_check => ['.cgi'] },
  { url => '/thruk/cgi-bin/status.cgi',             waitfor => 'New\ Test\ Business\ Process' },
  { url => '/thruk/cgi-bin/bp.cgi', post => { 'action' => 'remove', 'bp' => 1 }, skip_link_check => ['.cgi'] },
];

my $shared_urls = [
# business process
  { url => '/thruk/cgi-bin/bp.cgi?action=new&bp_label=New Test Business Process', like => '/New Test Business Process/', skip_link_check => ['.cgi'] },
  { url => '/thruk/cgi-bin/bp.cgi', post => { 'action' => 'commit', 'bp' => 1 }, like => '/New Test Business Process/', skip_link_check => ['.cgi'] },
  { url => '/thruk/cgi-bin/bp.cgi', post => { 'action' => 'remove', 'bp' => 1 }, skip_link_check => ['.cgi'] },
];

my $cookie_urls = [
  { url => '/thruk/cgi-bin/tac.cgi', like => '/Password/', unlike => [ '/internal server error/'] },
];


# complete the url
for my $url ( @{$urls}, @{$shared_urls}, @{$own_urls}, @{$cookie_urls} ) {
    $url->{'url'} = "http://localhost/".$site.$url->{'url'};
    $url->{'auth'}   = $auth;
    $url->{'unlike'} = [ '/internal server error/', '/"\/thruk\//', '/\'\/thruk\//' ] unless defined $url->{'unlike'};
    if($url->{'post'}) {
        $url->{'post'}->{'token'} = 'test';
    }
}

for my $core (qw/nagios icinga shinken/) {
    ##################################################
    # run our tests
    TestUtils::test_command({ cmd => $omd_bin." stop $site" });
    TestUtils::test_command({ cmd => $omd_bin." config $site set CORE $core" });
    TestUtils::test_command({ cmd => $omd_bin." config $site set APACHE_MODE own" });
    TestUtils::restart_system_apache();
    TestUtils::test_command({ cmd => $omd_bin." start $site" }) or TestUtils::bail_out_clean("No need to test Thruk without proper startup");
    TestUtils::wait_for_file("/omd/sites/$site/tmp/run/live")   or TestUtils::bail_out_clean("No need to test Thruk without livestatus connection");
    unlink("/omd/sites/$site/tmp/thruk/thruk.cache");
    unlink("/omd/sites/$site/var/thruk/obj_retention.dat");

    TestUtils::test_command({ cmd => "/bin/su - $site -c './bin/thruk -A omdadmin \"cmd.cgi?cmd_typ=7&cmd_mod=2&host=omd-$site&service=Dummy+Service&start_time=now&force_check=on&btnSubmit=Commit\" --local'", like => '/Command request successfully submitted/', errlike => '/cmd: COMMAND/' });
    TestUtils::wait_for_file("/omd/sites/$site/var/pnp4nagios/perfdata/omd-$site/Dummy_Service_omd-dummy.rrd") or TestUtils::bail_out_clean("No need to test Thruk without working pnp");;

    for my $test (@{$tests}) {
        TestUtils::test_command($test);
    }
    for my $test (@{$own_tests}) {
        TestUtils::test_command($test);
    }
    ##################################################
    # and request some pages
    for my $url ( @{$urls} ) {
        TestUtils::test_url($url);
    }
    for my $url ( @{$own_urls} ) {
        TestUtils::test_url($url);
    }

    ##################################################
    # switch webserver to shared mode
    TestUtils::test_command({ cmd => $omd_bin." stop $site" });
    TestUtils::test_command({ cmd => $omd_bin." config $site set APACHE_MODE shared" });
    TestUtils::restart_system_apache();
    TestUtils::test_command({ cmd => $omd_bin." start $site" });

    ##################################################
    # then run tests again
    for my $test (@{$tests}) {
        TestUtils::test_command($test);
    }
    for my $test (@{$shared_tests}) {
        TestUtils::test_command($test);
    }
    ##################################################
    # and request some pages
    for my $url ( @{$urls} ) {
        TestUtils::test_url($url);
    }
    for my $url ( @{$shared_urls} ) {
        TestUtils::test_url($url);
    }

    my $log  = "/omd/sites/$site/var/log/thruk.log";
    my $tlog = '/tmp/thruk_test_error.log';
    is(-f $log, 1, "log exists");
    # grep out commands
    `/bin/cat $log | /bin/grep -v 'cmd: COMMAND' | /bin/grep -v ' started ' | /bin/grep -v 'templates precompiled in' > $tlog 2>&1`;
    is(-s $tlog, 0, "log is empty") or diag(Dumper(`cat $log`));
    unlink($tlog);
}

##################################################
# enable cookie auth
TestUtils::test_command({ cmd => $omd_bin." stop $site" });
TestUtils::test_command({ cmd => $omd_bin." config $site set CORE nagios" });
TestUtils::test_command({ cmd => $omd_bin." config $site set APACHE_MODE own" });
TestUtils::test_command({ cmd => $omd_bin." config $site set THRUK_COOKIE_AUTH on" });
TestUtils::test_command({ cmd => $omd_bin." start $site", like => '/OK/' });
TestUtils::restart_system_apache();
TestUtils::test_command({ cmd => $omd_bin." start $site thruk", like => '/OK/' });
sleep(3);
TestUtils::test_command({ cmd => $omd_bin." status $site apache", like => '/running/' });
for my $url ( @{$cookie_urls} ) {
    TestUtils::test_url($url);
}

##################################################
# cleanup test site
TestUtils::restart_system_apache();
TestUtils::remove_test_site($site);


##################################################
sub set_test_user_token {
    my $file = '/omd/sites/'.$site.'/var/thruk/token';
    local $ENV{'CATALYST_CONFIG'} = '/omd/sites/'.$site.'/etc/thruk/';
    my $config = Thruk::Config::get_config();
    my $store  = Thruk::Utils::Cache->new($file);
    my $tokens = $store->get('token');
    $tokens->{'omdadmin'} = { token => 'test', time => time() };
    $store->set('token', $tokens);
    `chown $site:$site $file`;
    ok(-s $file, $file." exists") or TestUtils::bail_out_clean("no further testing without token");
    return;
}
