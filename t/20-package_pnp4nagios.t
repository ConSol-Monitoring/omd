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

plan( tests => 153 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

# create test host/service
TestUtils::prepare_obj_config('t/data/omd/testconf1', '/omd/sites/'.$site.'/etc/naemon/conf.d', $site);

# decrease pnp interval
TestUtils::test_command({ cmd => "/usr/bin/env sed -i -e 's/^perfdata_file_processing_interval = 15/perfdata_file_processing_interval = 2/g' -e 's/^sleep_time = 15/sleep_time = 2/g' /opt/omd/sites/$site/etc/pnp4nagios/npcd.cfg" });

##################################################
# prepare initial data
TestUtils::test_command({ cmd => $omd_bin." start $site" });
# submit a forced check, so we have initial perf data
TestUtils::test_command({ cmd => "/bin/su - $site -c './lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/thruk/cgi-bin/cmd.cgi -e 200 -P \"cmd_typ=7&cmd_mod=2&host=omd-$site&service=Dummy+Service&start_time=2010-11-06+09%3A46%3A02&force_check=on&btnSubmit=Commit\" -r \"Your command request was successfully submitted\"'", like => '/HTTP OK:/' });
TestUtils::wait_for_file("/omd/sites/$site/var/pnp4nagios/perfdata/omd-$site/Dummy_Service_omd-dummy.rrd") or TestUtils::bail_out_clean("No need to test pnp without existing rrd");;

# copy page test config
for my $cfg (qw/pages-static-ok.cfg pages-static-err.cfg pages-regex-ok.cfg pages-regex-err.cfg/) {
    ok(copy("t/data/pnp4nagios/$cfg", "/omd/sites/$site/etc/pnp4nagios/pages/$cfg"), "copy test config $cfg");
}

##################################################
# then execute some checks
my $tests = [
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -u /$site/pnp4nagios -e 401'",                           like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/pnp4nagios -e 301'",           like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/pnp4nagios/index.php -e 302'", like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/pnp4nagios/graph?host=omd-$site -e 200'", like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u \"/$site/pnp4nagios/graph?host=omd-$site&srv=Dummy+Service\" -e 200'", like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u \"/$site/pnp4nagios/image?host=omd-$site&srv=Dummy+Service\" -e 200'", like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u \"/$site/pnp4nagios/json?host=omd-$site\" -e 200'", like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u \"/$site/pnp4nagios/json?host=omd-$site&srv=Dummy+Service\" -e 200'", like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u \"/$site/pnp4nagios/mobile\" -e 200'", like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u \"/$site/pnp4nagios/mobile/overview\" -e 200'", like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u \"/$site/pnp4nagios/mobile/search\" -e 200'", like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u \"/$site/pnp4nagios/mobile/pages\" -e 200'", like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u \"/$site/pnp4nagios/mobile/host/omd-$site\" -e 200'", like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u \"/$site/pnp4nagios/mobile/host/omd-$site/Dummy+Service\" -e 200'", like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u \"/$site/pnp4nagios/pdf?host=omd-$site&srv=Dummy+Service\" -e 200'", like => '/HTTP OK:/' },
  #### pages ####
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/pnp4nagios/page?page=pages-static-ok -e 200'", like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/pnp4nagios/page?page=pages-regex-ok -e 200'", like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -vvv -u /$site/pnp4nagios/page?page=pages-static-err -e 200'", like => '/ERROR:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -vvv -u /$site/pnp4nagios/page?page=pages-regex-err -e 200'", like => '/ERROR:/' },
  { cmd => $omd_bin." stop $site" },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}

##################################################
# cleanup test site
TestUtils::remove_test_site($site);

##################################################
# Create test Site for npcd test

$site = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

# create test host/service
TestUtils::prepare_obj_config('t/data/omd/testconf1', '/omd/sites/'.$site.'/etc/naemon/conf.d', $site);

# decrease pnp interval
TestUtils::test_command({ cmd => "/usr/bin/env sed -i -e 's/^perfdata_file_processing_interval = 15/perfdata_file_processing_interval = 2/g' -e 's/^sleep_time = 15/sleep_time = 2/g' /opt/omd/sites/$site/etc/pnp4nagios/npcd.cfg" });

##################################################
# prepare initial data
TestUtils::test_command({ cmd => $omd_bin." config $site set PNP4NAGIOS npcd" });
TestUtils::test_command({ cmd => $omd_bin." start $site" });
# submit a forced check, so we have initial perf data
TestUtils::test_command({ cmd => "/bin/su - $site -c './lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/thruk/cgi-bin/cmd.cgi -e 200 -P \"cmd_typ=7&cmd_mod=2&host=omd-$site&service=Dummy+Service&start_time=2010-11-06+09%3A46%3A02&force_check=on&btnSubmit=Commit\" -r \"Your command request was successfully submitted\"'", like => '/HTTP OK:/' });
TestUtils::wait_for_file("/omd/sites/$site/var/pnp4nagios/perfdata/omd-$site/Dummy_Service_omd-dummy.rrd") or TestUtils::bail_out_clean("No need to test pnp without existing rrd");;


##################################################
# then execute some checks
$tests = [
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -u /$site/pnp4nagios -e 401'",                           like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/pnp4nagios -e 301'",           like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/pnp4nagios/index.php -e 302'", like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/pnp4nagios/graph?host=omd-$site -e 200'", like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u \"/$site/pnp4nagios/graph?host=omd-$site&srv=Dummy+Service\" -e 200'", like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u \"/$site/pnp4nagios/image?host=omd-$site&srv=Dummy+Service\" -e 200'", like => '/HTTP OK:/' },
  { cmd => $omd_bin." stop $site" },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}

##################################################
# cleanup test site
TestUtils::remove_test_site($site);

