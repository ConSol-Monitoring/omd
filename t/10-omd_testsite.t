#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

plan( tests => 44 );

########################################
# execute some commands
my $site  = 'testsite';
my $site2 = 'testsite2';
my $site3 = 'testsite3';
my $tests = [
  { cmd => "/usr/bin/omd versions",     exp => '/^\d+\.\d+/'  },
  { cmd => "/usr/bin/omd create $site", exp => '/Successfully created site '.$site.'./' },
  { cmd => "/usr/bin/omd sites",        exp => '/^'.$site.'\s+\d+\.\d+/' },
  { cmd => "/usr/bin/omd start $site",  exp => '/Starting nagios:/' },
  { cmd => "/usr/bin/omd status $site", exp => [
                                                '/apache:\s*running/',
                                                '/rrdcached:\s*running/',
                                                '/npcd:\s*running/',
                                                '/nagios:\s*running/',
                                                '/Overall state:\s*running/',
                                               ]
  },
  { cmd => "/usr/bin/omd stop $site",       exp => '/Stopping nagios:/' },
  { cmd => "/usr/bin/omd cp $site $site2",  exp => '/Cping site '.$site.' to '.$site2.'.../', errexp => '/Apache port \d+ is in use\. I\'ve choosen \d+ instead\./' },
  { cmd => "/usr/bin/omd mv $site2 $site3", exp => '/Mving site '.$site2.' to '.$site3.'.../' },
  { cmd => "/usr/bin/omd rm $site3",        exp => '/Restarting Apache...OK/', stdin => "yes\n" },
  { cmd => "/usr/bin/omd rm $site",         exp => '/Restarting Apache...OK/', stdin => "yes\n" },
];

# run tests
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}
