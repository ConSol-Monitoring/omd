#!/usr/bin/perl

use warnings;
use strict;
use POSIX;

sub check {
print "killing ".getpid()." now...\n";
print STDERR "killing $$ now...\n";
#kill(2, $$);
kill(11, $$);  # segv
kill(13, $$);  # pipe

exit 1;
}
check();
