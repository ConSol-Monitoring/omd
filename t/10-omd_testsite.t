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

plan skip_all => "test requires omd installation (/usr/bin/omd: $!)" unless -x '/usr/bin/omd';
plan( tests => 44 );

########################################
# execute some commands
my $site  = 'testsite';
my $site2 = 'testsite2';
my $site3 = 'testsite3';
my $tests = [
  { cmd => "/usr/bin/omd versions",     like => '/^\d+\.\d+/'  },
  { cmd => "/usr/bin/omd create $site", like => '/Successfully created site '.$site.'./' },
  { cmd => "/usr/bin/omd sites",        like => '/^'.$site.'\s+\d+\.\d+/' },
  { cmd => "/usr/bin/omd start $site",  like => '/Starting nagios/' },
  { cmd => "/usr/bin/omd status $site", like => [
                                                '/apache:\s*running/',
                                                '/rrdcached:\s*running/',
                                                '/npcd:\s*running/',
                                                '/nagios:\s*running/',
                                                '/Overall state:\s*running/',
                                               ]
  },
  { cmd => "/usr/bin/omd stop $site",       like => '/Stopping nagios/' },
  { cmd => "/usr/bin/omd cp $site $site2",  like => '/Copying site '.$site.' to '.$site2.'.../', errlike => '/Apache port \d+ is in use\. I\'ve choosen \d+ instead\./' },
  { cmd => "/usr/bin/omd mv $site2 $site3", like => '/Moving site '.$site2.' to '.$site3.'.../' },
  { cmd => "/usr/bin/omd rm $site3",        like => '/Restarting Apache...OK/', stdin => "yes\n" },
  { cmd => "/usr/bin/omd rm $site",         like => '/Restarting Apache...OK/', stdin => "yes\n" },
];

# run tests
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}
