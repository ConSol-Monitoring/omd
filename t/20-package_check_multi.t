#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
    use FindBin;
    use lib "$FindBin::Bin/lib/lib/perl5";
}

plan( tests => 144 );

# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or BAIL_OUT("no further testing without site");
my $auth    = 'OMD Monitoring Site '.$site.':omdadmin:omd';
my $host    = "omd-check_multi";

# prepare check_multi test environment (from skel/etc/check_multi/test)
TestUtils::test_command({ cmd => $omd_bin." config $site set WEB welcome" });
TestUtils::test_command({ cmd => "/bin/cp t/packages/check_multi/test/localhost.cfg /omd/sites/$site/etc/nagios/conf.d/check_multi_test.cfg" });
TestUtils::test_command({ cmd => "/usr/bin/test -d /omd/sites/$site/etc/check_multi || /bin/mkdir /omd/sites/$site/etc/check_multi" });
TestUtils::test_command({ cmd => "/bin/cp t/packages/check_multi/test/* /omd/sites/$site/etc/check_multi" });
TestUtils::test_command({ cmd => "/bin/sed 's/sleep_time = [0-9][0-9]/sleep_time = 5/' < /omd/sites/$site/etc/pnp4nagios/npcd.cfg > /omd/sites/$site/etc/pnp4nagios/npcd.cfg.new && mv /omd/sites/$site/etc/pnp4nagios/npcd.cfg.new /omd/sites/$site/etc/pnp4nagios/npcd.cfg && grep sleep_time /omd/sites/$site/etc/pnp4nagios/npcd.cfg",	like=> '/sleep_time = 5/' });
TestUtils::test_command({ cmd => "/bin/sed 's/perfdata_file_processing_interval = [0-9][0-9]/perfdata_file_processing_interval = 5/' < /omd/sites/$site/etc/pnp4nagios/npcd.cfg > /omd/sites/$site/etc/pnp4nagios/npcd.cfg.new && mv /omd/sites/$site/etc/pnp4nagios/npcd.cfg.new /omd/sites/$site/etc/pnp4nagios/npcd.cfg && grep perfdata_file_processing_interval /omd/sites/$site/etc/pnp4nagios/npcd.cfg",	like=> '/perfdata_file_processing_interval = 5/' });
TestUtils::test_command({ cmd => $omd_bin." start $site" });

# check_multi's own tests
TestUtils::test_command({ cmd => "/bin/sh -c '(cd packages/check_multi/check_multi/plugins/t; make OMD_SITE=test OMD_ROOT=/tmp test-all test-extreme)'" });

#=head2 test_url
#
#  test a url
#
#  needs test hash
#  {
#    url     => url to request
#    auth    => authentication (realm:user:pass)
#    code    => expected response code
#    like    => (list of) regular expressions which have to match content
#    unlike  => (list of) regular expressions which must not match content
#  }
#
#
my $urls = [
	{
		url => '/nagios/cgi-bin/status.cgi?host=all',
		like => [
			'/Service Status Details/',
			'/livestatus.*plugins checked/ms',
			'/nagios.*\d+ plugins checked/ms',
			'/pnp4nagios.*\d+ plugins checked/ms',
			'/rss.*\d+ plugins checked/ms',
			'/vsz.*\d+ plugins checked/ms',
			'/cpu.*\d+ plugins checked/ms',
			'/statusdat.*\d+ plugins checked/ms',
			'/system.*\d+ plugins checked/ms',
		],
		skip_html_lint=>1,
	},
	{
		url => '/thruk/cgi-bin/status.cgi?host=all',
		like => [
			'/Service Status Details/',
			'/livestatus.*plugins checked/ms',
			'/nagios.*\d+ plugins checked/ms',
			'/pnp4nagios.*\d+ plugins checked/ms',
			'/rss.*\d+ plugins checked/ms',
			'/vsz.*\d+ plugins checked/ms',
			'/cpu.*\d+ plugins checked/ms',
			'/statusdat.*\d+ plugins checked/ms',
			'/system.*\d+ plugins checked/ms',
		],
	},
	{
		url => "/nagios/cgi-bin/status.cgi?host=$host",
		like => [
			"/Service Status Details/",
			'/livestatus.*plugins checked/ms',
			'/nagios.*\d+ plugins checked/ms',
			'/pnp4nagios.*\d+ plugins checked/ms',
			'/rss.*\d+ plugins checked/ms',
			'/vsz.*\d+ plugins checked/ms',
			'/cpu.*\d+ plugins checked/ms',
			'/statusdat.*\d+ plugins checked/ms',
			'/system.*\d+ plugins checked/ms',
		],
		skip_html_lint=>1,
	},
	{
		url => "/nagios/cgi-bin/extinfo.cgi?type=2&host=$host&service=livestatus",
		like => [
			"/Service.*livestatus.*On Host.*$host/ms",
			'/livestatus.*plugins checked/ms',
			'/all_omd-check_multi_nagios.*\d+ plugins checked/ms',
			'/all_omd-check_multi_pnp4nagios.*pnp4nagios.*\d+ plugins checked/ms',
		],
	},
	{
		url => "/nagios/cgi-bin/extinfo.cgi?type=2&host=$host&service=statusdat",
		like => [
			'/Service.*statusdat.*On Host.*omd-check_multi/ms',
			'/all_omd-check_multi_livestatus.*plugins checked/ms',
			'/all_omd-check_multi_nagios.*.*\d+ plugins checked/ms',
			'/all_omd-check_multi_pnp4nagios.*pnp4nagios.*\d+ plugins checked/ms',
			'/all_omd-check_multi_proc_rss.*rss.*\d+ plugins checked/ms',
			'/all_omd-check_multi_proc_vsz.*vsz.*\d+ plugins checked/ms',
			'/all_omd-check_multi_proc_cpu.*cpu.*\d+ plugins checked/ms',
			'/all_omd-check_multi_statusdat.*statusdat.*\d+ plugins checked/ms',
			'/all_omd-check_multi_system.*system.*\d+ plugins checked/ms',
		],
	},
	{
		url => "/nagios/cgi-bin/extinfo.cgi?type=2&host=$host&service=pnp4nagios",
		like => [
			'/Service.*pnp4nagios/',
			'/pnp4nagios.*\d+ plugins checked/ms',
			'/rrdcached/',
			'/npcd/',
			'/var_diskspace/',
			'/var_updated_recently/',
			'/process_perfdata_timeout/',
			'/error_in_npcd_log/',
		],
	},
	{
		url => "/nagios/cgi-bin/extinfo.cgi?type=2&host=$host&service=nagios",
		like => [
			'/Service.*nagios.*On Host/',
			'/SITE.*testsite/',
			'/ROOT.*\/omd\/sites\/testsite/',
			'/check_nagios/',
			'/checkresults_dir/',
		],
	},
	{
		url => "/pnp4nagios/graph?host=$host&srv=disk_root",
		like => [
			'/Service details omd-check_multi.*disk_root/',
		],
	},
];

# complete the url
foreach my $url ( @{$urls} ) {
	$url->{'url'}		= "http://localhost/".$site.$url->{'url'};
	$url->{'auth'}		= $auth;
	$url->{'unlike'}	= [ '/internal server error/' ];
}

for my $core (qw/nagios/) {
	TestUtils::test_command({ cmd => $omd_bin." stop $site" });
	TestUtils::test_command({ cmd => $omd_bin." config $site set CORE $core" });
	TestUtils::test_command({ cmd => $omd_bin." start $site" });
	TestUtils::test_command({ cmd => "/bin/sed 's/escape_html_tags=[01]/escape_html_tags=0/' < /omd/sites/$site/etc/$core/cgi.cfg > /omd/sites/$site/etc/$core/cgi.cfg.new && mv /omd/sites/$site/etc/$core/cgi.cfg.new /omd/sites/$site/etc/$core/cgi.cfg && grep escape_html_tags /omd/sites/$site/etc/$core/cgi.cfg",	like=> '/escape_html_tags=0/' });
	TestUtils::test_command({ cmd => "/bin/su - $site -c './lib/nagios/plugins/check_http -t 30 -H localhost -a omdadmin:omd -u /$site/nagios/cgi-bin/cmd.cgi -e 200 -P \"cmd_typ=17&host=$host&cmd_mod=2&start_time=2010-11-06+09%3A46%3A02&force_check=on&btnSubmit=Commit\" -r \"Your command request was successfully submitted\"'", like => '/HTTP OK:/', sleep => 30 });

	for my $url ( @{$urls} ) {
		TestUtils::test_url($url);
	}
}

TestUtils::test_command({ cmd => TestUtils::config('APACHE_INIT')." restart" });
TestUtils::remove_test_site($site);
