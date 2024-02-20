#!/usr/bin/perl

use strict;
use warnings;
use utf8;

binmode(STDOUT, ":utf8");

printf("env lang: %s\n", $ENV{'LANG'});
printf("german: äöüß\n");
printf("eur: €\n");
exit(0);
