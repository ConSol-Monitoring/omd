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

plan( tests => 14 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or BAIL_OUT("no further testing without site");

##################################################
# execute some checks
my $tests = [
  { cmd => "/bin/su - $site -c '/usr/bin/env cpan'", stdin => "yes\n", like => '/cpan\[1\]>/' },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}

##################################################
SKIP: {
    skip('Author test. Set $ENV{TEST_AUTHOR} to a true value to run.', 4) unless $ENV{TEST_AUTHOR};
    my $author_tests = [
      { cmd => "/bin/su - $site -c '/usr/bin/env cpan'", stdin => "notest install Traceroute::Similar\n", like => '/install\s+\-\-\s+OK/' },
    ];
    for my $author_test (@{$author_tests}) {
        TestUtils::test_command($author_test);
    }
}

##################################################
# cleanup test site
TestUtils::remove_test_site($site);
