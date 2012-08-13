#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use File::Copy;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
    use FindBin;
    use lib "$FindBin::Bin/lib/lib/perl5";
}

unless($ENV{THRUK_AUTHOR}) {
  plan( skip_all => 'Thruk Author test. Set $ENV{THRUK_AUTHOR} to a true value to run.' );
} else {
  plan( tests => 69 );
}

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");
my $auth    = 'OMD Monitoring Site '.$site.':omdadmin:omd';

# decrease pnp interval
TestUtils::test_command({ cmd => "/usr/bin/env sed -i -e 's/^perfdata_file_processing_interval = 15/perfdata_file_processing_interval = 2/g' -e 's/^sleep_time = 15/sleep_time = 2/g' /opt/omd/sites/$site/etc/pnp4nagios/npcd.cfg" });

# set thruk as default
TestUtils::test_command({ cmd => $omd_bin." config $site set DEFAULT_GUI thruk" });

ok(copy("t/data/thruk/test_conf1.cfg", "/omd/sites/$site/etc/nagios/conf.d/test.cfg"), "copy test config to site dir");

TestUtils::test_command({ cmd => "/bin/su - $site -c './etc/init.d/nagios checkconfig'", like => '/Running configuration check\.\.\.\ done/' });
TestUtils::test_command({ cmd => $omd_bin." start $site" }) or TestUtils::bail_out_clean("No need to test Thruk without proper startup");
TestUtils::wait_for_file("/omd/sites/$site/tmp/run/live")   or TestUtils::bail_out_clean("No need to test Thruk without livestatus connection");

my $urls = [
  { url => '/thruk/cgi-bin/status.cgi?view_mode=xls&host=all', 'like' => [ '/Arial/' ] },
];

# complete the url
for my $url ( @{$urls} ) {
    $url->{'url'}    = "http://localhost/".$site.$url->{'url'};
    $url->{'auth'}   = $auth;
    $url->{'unlike'} = [ '/internal server error/', '/"\/thruk\//', '/\'\/thruk\//' ];
}

for my $core (qw/nagios shinken/) {
    ##################################################
    # run our tests
    TestUtils::test_command({ cmd => $omd_bin." stop $site" });
    TestUtils::test_command({ cmd => $omd_bin." config $site set CORE $core" });
    TestUtils::test_command({ cmd => $omd_bin." start $site" }) or TestUtils::bail_out_clean("No need to test Thruk without proper startup");
    TestUtils::wait_for_file("/omd/sites/$site/tmp/run/live")   or TestUtils::bail_out_clean("No need to test Thruk without livestatus connection");

    # request force command to create a rrd file
    TestUtils::test_command({ cmd => "/bin/su - $site -c './lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/nagios/cgi-bin/cmd.cgi -e 200 -P \"cmd_typ=7&cmd_mod=2&host=test_host&service=test_echo&start_time=2010-11-06+09%3A46%3A02&force_check=on&btnSubmit=Commit\" -r \"Your command request was successfully submitted\"'", like => '/HTTP OK:/' });
    TestUtils::test_command({ cmd => "/bin/su - $site -c './lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/nagios/cgi-bin/cmd.cgi -e 200 -P \"cmd_typ=7&cmd_mod=2&host=omd-$site&service=Dummy+Service&start_time=2010-11-06+09%3A46%3A02&force_check=on&btnSubmit=Commit\" -r \"Your command request was successfully submitted\"'", like => '/HTTP OK:/' });
    TestUtils::wait_for_file("/omd/sites/$site/var/pnp4nagios/perfdata/omd-$site/Dummy_Service_omd-dummy.rrd");

    ##################################################
    # and request some pages
    for my $url ( @{$urls} ) {
        TestUtils::test_url($url);
    }
}

##################################################
# cleanup test site
TestUtils::remove_test_site($site);
