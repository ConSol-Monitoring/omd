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
plan( tests => 38 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

##################################################
# execute some checks
my $tests = [
  { cmd => $omd_bin." config $site set CORE icinga2" },

  { cmd => "/bin/su - $site -c './etc/init.d/icinga2 check'",      errlike => '/Finished validating the configuration/' },
  { cmd => "/bin/su - $site -c './etc/init.d/icinga2 status'",     like => '/Not running/', exit => 1 },
  { cmd => $omd_bin." start $site" },
  { cmd => "/bin/su - $site -c './etc/init.d/icinga2 status'",     like => '/Running \(\d+\)/' },

  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -u /$site/icinga -e 401'",                  like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/icinga -e 301'",  like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/icinga/ -e 200'", like => '/HTTP OK:/' },

  { cmd => $omd_bin." stop $site" },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}

##################################################
# cleanup test site
TestUtils::remove_test_site($site);
