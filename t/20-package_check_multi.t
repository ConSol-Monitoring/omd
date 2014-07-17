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

plan( tests => 137 );

# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or BAIL_OUT("no further testing without site");
my $package = "check_multi";
my $host    = "omd-$package";
my $auth    = 'OMD Monitoring Site '.$site.':omdadmin:omd';

# create test host/service
TestUtils::prepare_obj_config('t/data/omd/testconf1', '/omd/sites/'.$site.'/etc/nagios/conf.d', $site);

# prepare check_multi test environment (from skel/etc/check_multi/test)
TestUtils::test_command({ cmd => $omd_bin." config $site set DEFAULT_GUI welcome" });
TestUtils::test_command({ cmd => "/bin/cp t/packages/check_multi/test/localhost.cfg /omd/sites/$site/etc/nagios/conf.d/check_multi_test.cfg" });
TestUtils::test_command({ cmd => "/usr/bin/test -d /omd/sites/$site/etc/check_multi || /bin/mkdir /omd/sites/$site/etc/check_multi" });
TestUtils::test_command({ cmd => "/bin/cp t/packages/check_multi/test/* /omd/sites/$site/etc/check_multi" });
TestUtils::test_command({ cmd => "/bin/sed -i -e 's/sleep_time = 15/sleep_time = 2/' -e 's/perfdata_file_processing_interval = 15/perfdata_file_processing_interval = 2/' /omd/sites/$site/etc/pnp4nagios/npcd.cfg" });
TestUtils::test_command({ cmd => "/bin/sed -i -e 's/log_external_commands=0/log_external_commands=1/' /omd/sites/$site/etc/shinken/shinken.d/logging.cfg" });
TestUtils::test_command({ cmd => "/bin/echo 'max_service_check_spread=1' >> /omd/sites/$site/etc/shinken/shinken.d/tuning.cfg" });
TestUtils::test_command({ cmd => $omd_bin." start $site" })   or TestUtils::bail_out_clean("No need to test $package without proper startup");
TestUtils::wait_for_file("/omd/sites/$site/tmp/run/live") or TestUtils::bail_out_clean("No need to test $package without livestatus connection");

# check_multi's own tests
#TestUtils::test_command({ cmd => "/bin/sh -c '(cd packages/check_multi/check_multi/plugins/t; make OMD_SITE=test OMD_ROOT=/tmp test-all test-extreme)'" });

my $urls = [
	{
		url => '/nagios/cgi-bin/status.cgi?host=all',
		like => [
			'/Service Status Details/',
			'/livestatus.*plugins checked/ms',
			'/nagios.*\d+ plugins checked/ms',
			'/pnp4nagios.*\d+ plugins checked/ms',
			'/statusdat.*\d+ plugins checked/ms',
			'/system.*\d+ plugins checked/ms',
		],
		skip_html_lint=>1,
	},
	{
		url => '/thruk/side.html', # startup fcgi daemon
	},
	{
		url => '/thruk/cgi-bin/status.cgi?host=all',
		like => [
			'/Service Status Details/',
			'/livestatus.*plugins checked/ms',
			'/nagios.*\d+ plugins checked/ms',
			'/pnp4nagios.*\d+ plugins checked/ms',
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
			'/statusdat.*\d+ plugins checked/ms',
			'/system.*\d+ plugins checked/ms',
		],
		skip_html_lint=>1,
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
#	{
#		url => "/nagios/cgi-bin/extinfo.cgi?type=2&host=$host&service=statusdat",
#		like => [
#			'/Service.*statusdat.*On Host.*omd-check_multi/ms',
#			#'/all_omd-check_multi_livestatus.*plugins checked/ms',
#			'/all_omd-check_multi_nagios.*\d+ plugins checked/ms',
#			'/all_omd-check_multi_pnp4nagios.*pnp4nagios.*\d+ plugins checked/ms',
#			'/all_omd-check_multi_.*statusdat.*\d+ plugins checked/ms',
#			'/all_omd-check_multi_system.*system.*\d+ plugins checked/ms',
#		],
#		unlike => [
#			"/read_status_dat: cannot open /omd/sites/$site/tmp/nagios/status.dat/ms",
#		],
#	},
#	{
#		url => "/nagios/cgi-bin/extinfo.cgi?type=2&host=$host&service=livestatus",
#		like => [
#			"/Service.*livestatus.*On Host.*$host/ms",
#			'/livestatus.*plugins checked/ms',
#			'/all_omd-check_multi_nagios.*\d+ plugins checked/ms',
#			'/all_omd-check_multi_pnp4nagios.*pnp4nagios.*\d+ plugins checked/ms',
#		],
#		unlike => [
#			"/all_omd-check_multi_.*: no output, no stderr - check your plugin and the tmp directory /omd/sites/$site/tmp/check_multi/ms",
#		],
#	},
];

# complete the url
foreach my $url ( @{$urls} ) {
	$url->{'url'} = "http://localhost/".$site.$url->{'url'};
	$url->{'auth'} = $auth;
	push @{$url->{'unlike'}}, '/internal server error/';
}

for my $core (qw/nagios/) {
	#--- perform proper initialization
	TestUtils::test_command({ cmd => $omd_bin." stop $site" });
	TestUtils::test_command({ cmd => $omd_bin." config $site set CORE $core" });
	TestUtils::test_command({ cmd => $omd_bin." start $site" })         or TestUtils::bail_out_clean("No need to test $package without proper startup");
    TestUtils::wait_for_file("/omd/sites/$site/tmp/run/nagios.cmd") or TestUtils::bail_out_clean("No need to test $package without proper startup");;

	#--- reschedule all checks and wait for result (note: shinken cmd.cgi is to be addressed via nagios CGIs)
	#TestUtils::test_command({ cmd => "/bin/su - $site -c './lib/nagios/plugins/check_http -t 30 -H localhost -a omdadmin:omd -u /$site/nagios/cgi-bin/cmd.cgi -e 200 -P \"cmd_typ=17&host=$host&cmd_mod=2&start_time=2222-22-22:22%3A22%3A22&force_check=on&btnSubmit=Commit\" -r \"Your command request was successfully submitted\"'", like => '/HTTP OK:/' });
	TestUtils::test_command({ cmd => "/bin/su - $site -c './lib/nagios/plugins/check_http -t 30 -H localhost -a omdadmin:omd -u /$site/nagios/cgi-bin/cmd.cgi -e 200 -P \"cmd_typ=7&cmd_mod=2&host=$host&service=nagios&start_time=2010-11-06+09%3A46%3A02&force_check=on&btnSubmit=Commit\" -r \"Your command request was successfully submitted\"'", like => '/HTTP OK:/' });
	TestUtils::test_command({ cmd => "/bin/su - $site -c './lib/nagios/plugins/check_http -t 30 -H localhost -a omdadmin:omd -u /$site/nagios/cgi-bin/cmd.cgi -e 200 -P \"cmd_typ=7&cmd_mod=2&host=$host&service=pnp4nagios&start_time=2010-11-06+09%3A46%3A02&force_check=on&btnSubmit=Commit\" -r \"Your command request was successfully submitted\"'", like => '/HTTP OK:/' });
	TestUtils::test_command({ cmd => "/bin/su - $site -c './lib/nagios/plugins/check_http -t 30 -H localhost -a omdadmin:omd -u /$site/nagios/cgi-bin/cmd.cgi -e 200 -P \"cmd_typ=7&cmd_mod=2&host=$host&service=system&start_time=2010-11-06+09%3A46%3A02&force_check=on&btnSubmit=Commit\" -r \"Your command request was successfully submitted\"'", like => '/HTTP OK:/' });
	TestUtils::test_command({ cmd => "/bin/su - $site -c './lib/nagios/plugins/check_http -t 30 -H localhost -a omdadmin:omd -u /$site/nagios/cgi-bin/cmd.cgi -e 200 -P \"cmd_typ=7&cmd_mod=2&host=$host&service=statusdat&start_time=2010-11-06+09%3A46%3A02&force_check=on&btnSubmit=Commit\" -r \"Your command request was successfully submitted\"'", like => '/HTTP OK:/' });
	TestUtils::test_command({ cmd => "/bin/su - $site -c './lib/nagios/plugins/check_http -t 30 -H localhost -a omdadmin:omd -u /$site/nagios/cgi-bin/cmd.cgi -e 200 -P \"cmd_typ=7&cmd_mod=2&host=$host&service=livestatus&start_time=2010-11-06+09%3A46%3A02&force_check=on&btnSubmit=Commit\" -r \"Your command request was successfully submitted\"'", like => '/HTTP OK:/' });

	#--- check_multi specific cgi.cfg setting
	TestUtils::test_command({ cmd => "/bin/sed -i -e 's/escape_html_tags=1/escape_html_tags=0/' /omd/sites/$site/etc/$core/cgi.cfg" });

	#--- wait for all services being checked
	TestUtils::wait_for_content(
		{ 
			url	=> "http://localhost/$site/nagios/cgi-bin/status.cgi?host=$host&servicestatustypes=1&hoststatustypes=15", 
			auth	=> "OMD Monitoring Site $site:omdadmin:omd",
			like	=> [ "0 of 0 Matching Services" ],
		}
	);

	TestUtils::wait_for_file("/omd/sites/$site/var/pnp4nagios/perfdata/omd-$site/Dummy_Service_omd-dummy.rrd");
	TestUtils::wait_for_file("/omd/sites/$site/tmp/run/live") or TestUtils::bail_out_clean("No need to test $package without livestatus connection");
	TestUtils::wait_for_file("/omd/sites/$site/tmp/nagios/status.dat") or TestUtils::bail_out_clean("No need to test $package without existing status.dat");

	for my $url ( @{$urls} ) {
		TestUtils::test_url($url);
	}
}

TestUtils::restart_system_apache();
TestUtils::remove_test_site($site);
