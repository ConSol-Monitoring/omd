#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use Data::Dumper;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
    use FindBin;
    use lib "$FindBin::Bin/lib/lib/perl5";
}

plan skip_all => 'Author test. Set $ENV{TEST_AUTHOR} to a true value to run.' unless $ENV{TEST_AUTHOR};
plan( tests => 12 );

my $omd_bin  = TestUtils::get_omd_bin();
my $site     = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");
my $versions_test = { cmd => $omd_bin." versions"};
TestUtils::test_command($versions_test);
my @versions = $versions_test->{'stdout'} =~ m/(^[0-9\.]+)$/mxg;
SKIP: {
    skip("cannot test update with only one version installed", 3) if scalar @versions == 0;
    TestUtils::test_command({ cmd => $omd_bin." -V $versions[0] update $site" });
}

##################################################
# cleanup test site
TestUtils::remove_test_site($site);
