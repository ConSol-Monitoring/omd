#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

plan( tests => 28 );

##################################################
# create our test site
my $site = TestUtils::create_test_site() or BAIL_OUT("no further testing without site");

##################################################
# execute some checks
my $tests = [
  { cmd => "/usr/bin/omd start $site" },

  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -u /$site/nagvis -e 401'",                  exp => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/nagvis -e 301'",  exp => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/nagvis/ -e 302'", exp => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/nagvis/frontend/nagvis-js/index.php -e 302'", exp => '/HTTP OK:/' },

  { cmd => "/usr/bin/omd stop $site" },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}

##################################################
# cleanup test site
TestUtils::remove_test_site($site);