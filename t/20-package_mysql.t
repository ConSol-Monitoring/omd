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
  { cmd => "/usr/bin/omd config $site set MYSQL on" },
  { cmd => "/usr/bin/omd config $site show MYSQL",  like => '/on/' },
  { cmd => "/usr/bin/omd start  $site" },
  { cmd => "/usr/bin/omd status $site",             like => '/mysql:\s*running/' },
  { cmd => "/bin/su - $site -c 'mysql mysql'", stdin => "show tables;\n", like => [ '/user/', '/tables_priv/' ] },
  { cmd => "/usr/bin/omd stop   $site" },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}

##################################################
# cleanup test site
TestUtils::remove_test_site($site);
