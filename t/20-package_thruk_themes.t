#!/usr/bin/env perl

use lib('t');
use lib '/omd/versions/default/lib/perl5/lib/perl5/';

use warnings;
use strict;
use Test::More;
use Data::Dumper;


unless(-d "distros") {
    plan( skip_all => 'need distros directory to run, please run from the project root' );
}

use_ok("TestUtils") or BAIL_OUT("fatal error in TestUtils");

chdir('/omd/versions/default/share/thruk/');

my @themes = split(/\n/mx, `ls -1 themes/themes-available/`);

# check if all themes have at least all images from the Classic theme
my @images = glob("./themes/themes-available/Classic/images/*.{png,jpg,gif}");
for my $theme (@themes) {
    for my $img (@images) {
        $img =~ s/.*\///gmx;
        ok(-f "./themes/themes-available/$theme/images/$img", "$img available in $theme");
    }
}

done_testing();
