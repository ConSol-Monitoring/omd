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

plan( tests => 219 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or BAIL_OUT("no further testing without site");
my $auth    = 'OMD Monitoring Site '.$site.':omdadmin:omd';
my $host    = "omd-check_multi";

# prepare check_multi test environment (from skel/etc/check_multi/test)
TestUtils::test_command({ cmd => $omd_bin." config $site set WEB welcome" });
TestUtils::test_command({ cmd => "/bin/cp t/packages/check_multi/test/localhost.cfg /omd/sites/$site/etc/nagios/conf.d/check_multi_test.cfg" });
TestUtils::test_command({ cmd => "/bin/mkdir /omd/sites/$site/etc/check_multi" });
TestUtils::test_command({ cmd => "/bin/cp t/packages/check_multi/test/* /omd/sites/$site/etc/check_multi" });
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
	{ url => "/nagios/cgi-bin/status.cgi?host=all",					like => '/system.*plugins checked/',	skip_html_lint=>1 	},
	{ url => "/nagios/cgi-bin/status.cgi?host=$host",				like => '/Service Status Details For Host/', skip_html_lint=>1	},
	{ url => "/nagios/cgi-bin/extinfo.cgi?type=2&host=$host&service=livestatus",	like => '/livestatus/'						},
	{ url => "/nagios/cgi-bin/extinfo.cgi?type=2&host=$host&service=statusdat",	like => '/statusdat/'						},
	{ url => "/nagios/cgi-bin/extinfo.cgi?type=2&host=$host&service=pnp4nagios",	like => '/pnp4nagios.*pnp4nagios.*plugins checked/'		},
	{ url => "/nagios/cgi-bin/extinfo.cgi?type=2&host=$host&service=nagios",	like => '/nagios.*plugins checked.*SITE.*ROOT.*tmp_dir.*proc_nagios_inst.*checkresults_dir/'},
	{ url => "/nagios/cgi-bin/extinfo.cgi?type=2&host=$host&service=nagios",	like => '/proc_nagios_inst/'					},
	{ url => "/nagios/cgi-bin/extinfo.cgi?type=2&host=$host&service=proc_rss",	like => '/proc_rss/'						},
	{ url => "/nagios/cgi-bin/extinfo.cgi?type=2&host=$host&service=proc_vsz",	like => '/proc_vsz/'						},
	{ url => "/pnp4nagios/graph?host=$host&srv=disk_root",				like => '/Service.*disk_root/'					},
	{ url => "/nagios/cgi-bin/extinfo.cgi?type=2&host=$host&service=nagios",	like => '/plugins checked.*SITE.*ROOT/'				},
	{ url => "/nagios/cgi-bin/extinfo.cgi?type=2&host=$host&service=livestatus",	like => '/livestatus.*plugins checked/'				},
	{ url => "/nagios/cgi-bin/extinfo.cgi?type=2&host=$host&service=statusdat",	like => '/statusdat.*plugins checked/'				},
	#{ url => "",      like => '//' },
];

# complete the url
foreach my $url ( @{$urls} ) {
	$url->{'url'}			= "http://localhost/".$site.$url->{'url'};
	$url->{'auth'}			= $auth;
	$url->{'unlike'}		= [ '/internal server error/' ];
	#$url->{'skip_html_lint'}	= 1;
}

#for my $core (qw/shinken nagios/) {
#for my $core (qw/nagios/) {
#for my $core (qw/shinken/) {
for my $core (qw/nagios shinken/) {
	##################################################
	# run our tests
	TestUtils::test_command({ cmd => $omd_bin." stop $site" });
	TestUtils::test_command({ cmd => $omd_bin." config $site set CORE $core" });
	TestUtils::test_command({ cmd => $omd_bin." start $site" });
	TestUtils::test_command({ cmd => "/bin/sed 's/escape_html_tags=[01]/escape_html_tags=0/' < /omd/sites/$site/etc/$core/cgi.cfg > /omd/sites/$site/etc/$core/cgi.cfg.new && mv /omd/sites/$site/etc/$core/cgi.cfg.new /omd/sites/$site/etc/$core/cgi.cfg && grep escape_html_tags /omd/sites/$site/etc/$core/cgi.cfg",	like=> '/escape_html_tags=0/' });
	TestUtils::test_command({ cmd => "/bin/su - $site -c './lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/nagios/cgi-bin/cmd.cgi -e 200 -P \"cmd_typ=17&host=$host&cmd_mod=2&start_time=2010-11-06+09%3A46%3A02&force_check=on&btnSubmit=Commit\" -r \"Your command request was successfully submitted\"'", like => '/HTTP OK:/', sleep => 30 });
	#TestUtils::test_command({ cmd => "/bin/su - $site -c './lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/nagios/cgi-bin/cmd.cgi -e 200 -P \"cmd_typ=17&cmd_mod=2&host=$host&force_check=on&start_time=2010-11-06+09%3A46%3A02&btnSubmit=Commit\" -r \"Your command request was successfully submitted\"'", like => '/HTTP OK:/', sleep => 10 });
	###############################################
	# and request some pages
	for my $url ( @{$urls} ) {
		TestUtils::test_url($url);
	}
}

##################################################
# cleanup test site
TestUtils::test_command({ cmd => TestUtils::config('APACHE_INIT')." restart" });
TestUtils::remove_test_site($site);
