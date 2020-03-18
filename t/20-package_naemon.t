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

plan( tests => 34 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

##################################################
# execute some checks
my $tests = [
  { cmd => $omd_bin." config $site set CORE naemon" },

  { cmd => $omd_bin." start $site" },

  { cmd => "/bin/su - $site -c 'test -S tmp/run/live'", like => '/^$/' },
  { cmd => "/bin/su - $site -c 'test -p tmp/run/naemon.cmd'", like => '/^$/' },
  { cmd => "/bin/su - $site -c 'test -f var/naemon/livestatus.log'", like => '/^$/' },

#  { cmd => "/bin/su - $site -c 'file bin/naemon.dbg'", like => '/not stripped/' },
#  { cmd => "/bin/su - $site -c 'file lib/naemon/livestatus.o.dbg'", like => '/not stripped/' },
#  { cmd => "/bin/su - $site -c 'file lib/mod_gearman/mod_gearman_naemon.o.dbg'", like => '/not stripped/' },

  { cmd => $omd_bin." stop $site naemon", unlike => '/kill/i' },
  { cmd => $omd_bin." stop $site" },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}

##################################################
# cleanup test site
TestUtils::remove_test_site($site);
