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

plan tests => 2;

my $omd_bin = TestUtils::get_omd_bin();

ok(-f $omd_bin, $omd_bin." exists");
ok(-x $omd_bin, $omd_bin." is executable");
