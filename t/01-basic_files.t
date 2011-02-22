#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

use lib('t');
use FindBin;
use lib "$FindBin::Bin/lib/lib/perl5";

plan tests => 3;

use_ok("TestUtils") or BAIL_OUT("fatal error in TestUtils");

my $omd_bin = TestUtils::get_omd_bin();

ok(-f $omd_bin, $omd_bin." exists");
ok(-x $omd_bin, $omd_bin." is executable");
