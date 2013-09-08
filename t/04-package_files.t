#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

plan skip_all => 'you need to specify OMD_PACKAGE for this test' unless defined $ENV{'OMD_PACKAGE'};

my $file = $ENV{'OMD_PACKAGE'};
ok(-f $file, "file: $file exists");

# debian packages
if($file =~ m/\.deb/gmx) {
    my $content = `dpkg -c $file 2>&1`;
    is($?, 0, 'got package content');
    my @files = split("\n", $content);
    ok(scalar @files > 0, 'got package '.(scalar @files).' files');
    for my $e (@files) {
        my($mode, $usr, $ref, $date, $time, $path) = split(/\s+/mx, $e);
        next if file_ok($path);
        fail("pkg contains unusual file: $e");
    }
}
elsif($file =~ m/\.rpm/gmx) {
    my $content = `rpm -qpl $file 2>&1`;
    is($?, 0, 'got package content');
    my @files = split("\n", $content);
    ok(scalar @files > 0, 'got package '.(scalar @files).' files');
    for my $e (@files) {
        next if file_ok($e);
        fail("pkg contains unusual file: $e");
    }
}
else {
    fail("unsupported pkg: $file");
}

done_testing();

#################################################
sub file_ok {
    my($file) = @_;
    $file =~ s/^\.//gmx;
    return 1 if $file =~ m|/opt/|;
    return 1 if $file =~ m|/usr/share/doc/omd|;
    return 1 if $file =~ m|/etc/init.d/omd|;
    return 1 if $file =~ m|/usr/share/man/|;
    return 1 if $file eq '/';
    return 1 if $file eq '/etc/';
    return 1 if $file eq '/etc/init.d/';
    return 1 if $file eq '/usr/';
    return 1 if $file eq '/usr/share/';
    return 1 if $file eq '/usr/share/doc/';
    return;
}

