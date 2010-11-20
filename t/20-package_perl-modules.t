#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

plan( tests => 14 );

##################################################
# create our test site
my $site = TestUtils::create_test_site() or BAIL_OUT("no further testing without site");

##################################################
# execute some checks
my $tests = [
  { cmd => "/bin/su - $site -c '/usr/bin/env cpan'", stdin => "yes\n", like => '/cpan\[1\]>/' },
  { cmd => "/bin/su - $site -c '/usr/bin/env cpan'", stdin => "notest install Traceroute::Similar\n", like => '/install\s+\-\-\s+OK/' },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}

##################################################
# cleanup test site
TestUtils::remove_test_site($site);
