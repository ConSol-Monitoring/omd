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

plan skip_all => "icinga2 not included, cannot test" unless -x '/omd/versions/default/bin/icinga2';
plan( tests => 71 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

##################################################
# prepare site
my $prepares = [
  { cmd => $omd_bin." config $site set CORE icinga2" },

  { cmd => "/bin/su - $site -c './etc/init.d/icinga2 check'",      errlike => '/Finished validating the configuration/' },
  { cmd => "/bin/su - $site -c './etc/init.d/icinga2 status'",     like => '/Not running/', exit => 1 },
  { cmd => $omd_bin." start $site" },
  { cmd => "/bin/su - $site -c './etc/init.d/icinga2 status'",     like => '/Running \(\d+\)/' },
];
for my $p (@{$prepares}) {
    TestUtils::test_command($p);
}

TestUtils::wait_for_file("/omd/sites/$site/tmp/run/live") or TestUtils::bail_out_clean("No need to test icinga2 without existing livestatus socket");


##################################################
# execute some checks
my $tests = [
  { cmd => "/bin/su - $site -c 'echo -e \"".'GET status\nColumns: program_start program_version\n'."\" | lq'", like => ['/\d+/', '/;r2\./'] },

  { cmd => $omd_bin." stop $site" },

  { cmd => $omd_bin." config $site set MYSQL on" },
  { cmd => $omd_bin." config $site set ICINGA2_IDO mysql" },
  { cmd => $omd_bin." start $site", like => '/creating initial ido database/' },
  { cmd => "/bin/su - $site -c 'echo \"select process_id from icinga_programstatus\" | mysql icinga'", like => ['/\d+/', '/process_id/'], waitfor => '\d+' },
  { cmd => "/bin/su - $site -c 'test -f share/icinga2-ido-pgsql/schema/pgsql.sql'", like => ['/^$/'] },

  { cmd => "/bin/su - $site -c 'icinga2 feature list'", like => ['/livestatus/', '/Enabled features:/'] },
  { cmd => "/bin/su - $site -c 'icinga2 feature enable debuglog'", like => ['/Enabling feature debuglog/'] },
  { cmd => "/bin/su - $site -c 'icinga2 feature disable debuglog'", like => ['/Disabling feature debuglog./'] },

  { cmd => $omd_bin." stop $site" },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}

##################################################
# cleanup test site
TestUtils::remove_test_site($site);
