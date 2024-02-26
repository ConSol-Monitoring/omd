#!/usr/bin/perl

use strict;
use warnings;
no warnings 'utf8';

print("OK: here are some probably none-printable characters...\n");
for my $ch (1, 2, 5, 6, 132, 0xe2, 0x194, 0xD801, 0xDFFE, 0xDFFF, 0x1F600, 0xFFFF, 0x1F984, 0x1202B, 0x4000001, 0) {
    printf("dec %10s / hex %10s : '", sprintf("%d", $ch), sprintf("0x%X", $ch));
    print chr($ch);
    print "'\n";
}

print "done. All characters printed.\n";
exit(0);
