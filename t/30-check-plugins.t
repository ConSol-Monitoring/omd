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

##################################################
# create our test site
our $omd_bin = TestUtils::get_omd_bin();
our $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

TestUtils::test_command({ cmd => $omd_bin." start $site", like => '/Starting/' });

##################################################
# run sub tests
my @subtests = glob("packages/check_plugins/*/*.t");
for my $subtest (@subtests) {
    ok(1, "subtest: $subtest");
    local $/ = undef;
    open(my $fh, $subtest) or die "Couldn't open file: $!";
    binmode $fh;
    my $data = <$fh>;
    close $fh;
    eval($data);
    is($@, "", "error output is empty");
}

##################################################
# cleanup test site
TestUtils::remove_test_site($site);

done_testing();
