#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

print "test output coming...\n";
print $0;
print " ";
print join(" ", @ARGV);
print "\n";
print Dumper(\%ENV);
print Dumper(\@ARGV);
exit(0);
