#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

plan( tests => 40 );

##################################################
# create our test site
my $site = TestUtils::create_test_site() or BAIL_OUT("no further testing without site");

##################################################
# execute some checks
my $tests = [
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -u /$site -e 503' -r \"OMD: Site Not Started\"",  exp => '/HTTP OK:/' },

  { cmd => "/usr/bin/omd start $site" },

  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -u /$site -e 302'",                      exp => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -u /$site/ -e 302'",                     exp => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -u /$site/omd -e 401'",                  exp => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site -e 302'",      exp => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/omd -e 301'",  exp => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/omd/ -e 200'", exp => '/HTTP OK:/' },

  { cmd => "/usr/bin/omd stop $site" },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}

##################################################
# cleanup test site
TestUtils::remove_test_site($site);