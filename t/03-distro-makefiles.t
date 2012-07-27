#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use Data::Dumper;

use lib('t');
use FindBin;
use lib "$FindBin::Bin/lib/lib/perl5";

unless(-d "distros") {
    plan( skip_all => 'need distros directory to run, please run from the project root' );
}

use_ok("TestUtils") or BAIL_OUT("fatal error in TestUtils");

my $all_confs = {};
my $all_keys  = {};
for my $file (glob("distros/Makefile.*")) {
    my $conf = TestUtils::read_config($file);
    isnt($conf, undef, "read config from $file");
    $all_confs->{$file} = $conf;
    for my $key (keys %{$all_confs->{$file}}) {
        $all_keys->{$key} = 1;
    }
}

for my $file (keys %{$all_confs}) {
    for my $key (keys %{$all_keys}) {
        next if $key eq 'ARCH'; # arch is debian specific
        next if $key eq 'CONFIG_SITE'; # CONFIG_SITE is OpenSuSE specific
        ok(exists($all_confs->{$file}->{$key}), "$file: $key");
    }
}

done_testing();
