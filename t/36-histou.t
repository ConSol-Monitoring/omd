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

my $php_version = `php -v`;
$php_version =~ s%^PHP\ (\d\.\d).*%$1%gmsx;
plan skip_all => "icinga2 not included, cannot test" unless -x '/omd/versions/default/bin/icinga2';
plan( skip_all => 'histou requires at least php 5.3') if $php_version < 5.3;
plan( tests => 49 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");
my $host    = `hostname`;
chomp($host);
my $service = 'load';

TestUtils::test_command({ cmd => $omd_bin." config $site set INFLUXDB on" });
TestUtils::test_command({ cmd => $omd_bin." config $site set NAGFLUX on" });
TestUtils::test_command({ cmd => $omd_bin." config $site set PNP4NAGIOS off" });
TestUtils::test_command({ cmd => $omd_bin." config $site set GRAFANA on" });
TestUtils::test_command({ cmd => $omd_bin." config $site set CORE icinga2" });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'rm etc/icinga2/conf.d/pnp4nagios.conf'", like => '/^\s*$/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'sed -i etc/icinga2/conf.d/histou.conf -e \'s/-perf/-pnp/g\''", like => '/^\s*$/' });

TestUtils::test_command({ cmd => $omd_bin." start $site", like => '/Starting influxdb.+OK/' });

TestUtils::test_command({ cmd => "/bin/su - $site -c 'echo \"COMMAND [".time()."] SCHEDULE_FORCED_SVC_CHECK;$host;$service;".time()."\" | lq'", like => '/^\s*$/' });

my $test = {
    url            => "http://localhost/$site/histou/index.php?host=$host&service=$service",
    auth           => "OMD Monitoring Site $site:omdadmin:omd",
    like           => [ "/\[title\]/", "/panels/", "/FROM messages WHERE/" ],
    waitfor        => "$host-$service",
};
my $page = TestUtils::test_url($test);
if($page->{'content'} !~ m/$host-$service/mx) {
    TestUtils::_diag_request($test, $page);
    TestUtils::bail_out_clean("histou did not work");
}

TestUtils::test_url({
    url            => "http://localhost/$site/grafana/public/dashboards/histou.js",
    auth           => "OMD Monitoring Site $site:omdadmin:omd",
    like           => [ "/return function/" ],
});

TestUtils::test_url({
    url            => "http://localhost/$site/grafana/dashboard-solo/script/histou.js?host=$host&service=$service&theme=light&panelId=1",
    auth           => "OMD Monitoring Site $site:omdadmin:omd",
    like           => [ "/>Grafana</" ],
    skip_html_lint => 1,
});


TestUtils::test_command({ cmd => $omd_bin." stop $site" });
TestUtils::remove_test_site($site);

