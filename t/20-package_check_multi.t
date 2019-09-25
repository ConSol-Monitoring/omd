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

plan( tests => 125 );

# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or BAIL_OUT("no further testing without site");
my $package = "check_multi";
my $host    = "omd-$package";
my $auth    = 'OMD Monitoring Site '.$site.':omdadmin:omd';

# create test host/service
TestUtils::prepare_obj_config('t/data/omd/testconf1', '/omd/sites/'.$site.'/etc/naemon/conf.d', $site);

# prepare check_multi test environment (from skel/etc/check_multi/test)
TestUtils::test_command({ cmd => $omd_bin." config $site set DEFAULT_GUI welcome" });
TestUtils::test_command({ cmd => "/bin/cp t/packages/check_multi/test/localhost.cfg /omd/sites/$site/etc/naemon/conf.d/check_multi_test.cfg" });
TestUtils::test_command({ cmd => "/usr/bin/test -d /omd/sites/$site/etc/check_multi || /bin/mkdir /omd/sites/$site/etc/check_multi" });
TestUtils::test_command({ cmd => "/bin/cp t/packages/check_multi/test/* /omd/sites/$site/etc/check_multi" });
TestUtils::test_command({ cmd => "/bin/sed -i -e 's/sleep_time = 15/sleep_time = 2/' -e 's/perfdata_file_processing_interval = 15/perfdata_file_processing_interval = 2/' /omd/sites/$site/etc/pnp4nagios/npcd.cfg" });
TestUtils::test_command({ cmd => $omd_bin." start $site" })   or TestUtils::bail_out_clean("No need to test $package without proper startup");
TestUtils::wait_for_file("/omd/sites/$site/tmp/run/live") or TestUtils::bail_out_clean("No need to test $package without livestatus connection");

# check_multi's own tests
#TestUtils::test_command({ cmd => "/bin/sh -c '(cd packages/check_multi/check_multi/plugins/t; make OMD_SITE=test OMD_ROOT=/tmp test-all test-extreme)'" });

my $urls = [
	{
		url => '/thruk/side.html', # startup fcgi daemon
	},
	{
		url => '/thruk/cgi-bin/status.cgi?host=all',
		like => [
			'/Service Status Details/',
			'/livestatus.*plugins checked/ms',
			'/naemon.*\d+ plugins checked/ms',
			'/pnp4nagios.*\d+ plugins checked/ms',
			'/statusdat.*\d+ plugins checked/ms',
			'/system.*\d+ plugins checked/ms',
		],
	},
	{
		url => "/thruk/cgi-bin/status.cgi?host=$host",
		like => [
			"/Service Status Details/",
			'/livestatus.*plugins checked/ms',
			'/naemon.*\d+ plugins checked/ms',
			'/pnp4nagios.*\d+ plugins checked/ms',
			'/statusdat.*\d+ plugins checked/ms',
			'/system.*\d+ plugins checked/ms',
		],
		skip_html_lint=>1,
	},
	{
		url => "/thruk/cgi-bin/extinfo.cgi?type=2&host=$host&service=pnp4nagios",
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
		url => "/thruk/cgi-bin/extinfo.cgi?type=2&host=$host&service=naemon",
		like => [
			'/Service.*naemon.*On Host/s',
			'/SITE.*testsite/',
			'/ROOT.*\/omd\/sites\/testsite/',
			'/check_naemon/',
			'/checkresults_dir/',
		],
	},
	{
		url => "/pnp4nagios/graph?host=$host&srv=disk_root",
		like => [
			'/Service details omd-check_multi.*disk_root/',
		],
		skip_link_check => [
			'\/testsite\/thruk\/cgi-bin\/avail.cgi\?show_log_entries=&host=omd-check_multi&service=disk_root',
		],
	},
];

# complete the url
foreach my $url ( @{$urls} ) {
	$url->{'url'} = "http://localhost/".$site.$url->{'url'};
	$url->{'auth'} = $auth;
	push @{$url->{'unlike'}}, '/internal server error/';
}

for my $core (qw/naemon/) {
	#--- perform proper initialization
	TestUtils::test_command({ cmd => $omd_bin." stop $site" });
	TestUtils::test_command({ cmd => $omd_bin." config $site set CORE $core" });
	TestUtils::test_command({ cmd => $omd_bin." start $site" })         or TestUtils::bail_out_clean("No need to test $package without proper startup");
    TestUtils::wait_for_file("/omd/sites/$site/tmp/run/naemon.cmd") or TestUtils::bail_out_clean("No need to test $package without proper startup");;

	#--- reschedule all checks and wait for result
	TestUtils::test_command({ cmd => "/bin/su - $site -c './lib/monitoring-plugins/check_http -t 30 -H localhost -a omdadmin:omd -u /$site/thruk/cgi-bin/cmd.cgi -e 200 -P \"cmd_typ=7&cmd_mod=2&host=$host&service=naemon&start_time=2010-11-06+09%3A46%3A02&force_check=on&btnSubmit=Commit\" -r \"Your command request was successfully submitted\"'", like => '/HTTP OK:/' });
	TestUtils::test_command({ cmd => "/bin/su - $site -c './lib/monitoring-plugins/check_http -t 30 -H localhost -a omdadmin:omd -u /$site/thruk/cgi-bin/cmd.cgi -e 200 -P \"cmd_typ=7&cmd_mod=2&host=$host&service=pnp4nagios&start_time=2010-11-06+09%3A46%3A02&force_check=on&btnSubmit=Commit\" -r \"Your command request was successfully submitted\"'", like => '/HTTP OK:/' });
	TestUtils::test_command({ cmd => "/bin/su - $site -c './lib/monitoring-plugins/check_http -t 30 -H localhost -a omdadmin:omd -u /$site/thruk/cgi-bin/cmd.cgi -e 200 -P \"cmd_typ=7&cmd_mod=2&host=$host&service=system&start_time=2010-11-06+09%3A46%3A02&force_check=on&btnSubmit=Commit\" -r \"Your command request was successfully submitted\"'", like => '/HTTP OK:/' });
	TestUtils::test_command({ cmd => "/bin/su - $site -c './lib/monitoring-plugins/check_http -t 30 -H localhost -a omdadmin:omd -u /$site/thruk/cgi-bin/cmd.cgi -e 200 -P \"cmd_typ=7&cmd_mod=2&host=$host&service=statusdat&start_time=2010-11-06+09%3A46%3A02&force_check=on&btnSubmit=Commit\" -r \"Your command request was successfully submitted\"'", like => '/HTTP OK:/' });
	TestUtils::test_command({ cmd => "/bin/su - $site -c './lib/monitoring-plugins/check_http -t 30 -H localhost -a omdadmin:omd -u /$site/thruk/cgi-bin/cmd.cgi -e 200 -P \"cmd_typ=7&cmd_mod=2&host=$host&service=livestatus&start_time=2010-11-06+09%3A46%3A02&force_check=on&btnSubmit=Commit\" -r \"Your command request was successfully submitted\"'", like => '/HTTP OK:/' });

	#--- check_multi specific cgi.cfg setting
	TestUtils::test_command({ cmd => "/bin/sed -i -e 's/escape_html_tags=1/escape_html_tags=0/' /omd/sites/$site/etc/thruk/cgi.cfg" });

	#--- wait for all services being checked
	TestUtils::wait_for_content(
		{ 
			url	=> "http://localhost/$site/thruk/cgi-bin/status.cgi?host=$host&servicestatustypes=1&hoststatustypes=15", 
			auth	=> "OMD Monitoring Site $site:omdadmin:omd",
			like	=> [ "0 Matching Service Entries Displayed" ],
		}
	);

	TestUtils::wait_for_file("/omd/sites/$site/var/pnp4nagios/perfdata/omd-$site/Dummy_Service_omd-dummy.rrd");
	TestUtils::wait_for_file("/omd/sites/$site/tmp/run/live") or TestUtils::bail_out_clean("No need to test $package without livestatus connection");
	TestUtils::wait_for_file("/omd/sites/$site/tmp/naemon/status.dat") or TestUtils::bail_out_clean("No need to test $package without existing status.dat");

	for my $url ( @{$urls} ) {
		TestUtils::test_url($url);
	}
}

TestUtils::restart_system_apache();
TestUtils::remove_test_site($site);
