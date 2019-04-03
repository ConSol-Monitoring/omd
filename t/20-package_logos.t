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

plan( tests => 44 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

##################################################
# execute some checks
my $tests = [
  { cmd => $omd_bin." start $site" },

  { cmd => "/bin/su - $site -c 'cp share/logos/internet.gif local/share/logos/local.gif'",  like => '/^$/' },
  { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -H localhost -a omdadmin:omd -u /$site/logos/internet.gif -e 200'",  like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -H localhost -a omdadmin:omd -u /$site/logos/local.gif -e 200'", like => '/HTTP OK:/' },

  { cmd => $omd_bin." stop $site" },
  { cmd => $omd_bin." config $site set THRUK_COOKIE_AUTH on" },
  { cmd => $omd_bin." start $site" },

  { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -H localhost -a omdadmin:omd -u /$site/logos/internet.gif -e 200'",  like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -H localhost -a omdadmin:omd -u /$site/logos/local.gif -e 200'", like => '/HTTP OK:/' },

  { cmd => $omd_bin." stop $site" },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}

##################################################
# cleanup test site
TestUtils::remove_test_site($site);
