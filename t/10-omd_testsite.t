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

plan( tests => 47 );

my $omd_bin = TestUtils::get_omd_bin();

########################################
# execute some commands
my $site  = 'testsite';
my $site2 = 'testsite2';
my $site3 = 'testsite3';
my $tests = [
  { cmd => $omd_bin." versions",     like => '/^\d+\.\d+/'  },
  { cmd => $omd_bin." rm $site",     stdin => "yes\n", 'exit' => undef, errlike => undef },
  { cmd => $omd_bin." rm $site2",    stdin => "yes\n", 'exit' => undef, errlike => undef },
  { cmd => $omd_bin." rm $site2",    stdin => "yes\n", 'exit' => undef, errlike => undef },
  { cmd => $omd_bin." create $site", like => '/Successfully created site '.$site.'./' },
  { cmd => $omd_bin." sites",        like => '/^'.$site.'\s+\d+\.\d+/' },
  { cmd => $omd_bin." start $site",  like => '/Starting nagios/' },
  { cmd => $omd_bin." status $site", like => [
                                                '/apache:\s*running/',
                                                '/rrdcached:\s*running/',
                                                '/npcd:\s*running/',
                                                '/nagios:\s*running/',
                                                '/Overall state:\s*running/',
                                               ]
  },
  { cmd => $omd_bin." stop $site",       like => '/Stopping nagios/' },
  { cmd => $omd_bin." cp $site $site2",  like => '/Copying site '.$site.' to '.$site2.'.../', errlike => '/Apache port \d+ is in use\. I\'ve choosen \d+ instead\./' },
  { cmd => $omd_bin." mv $site2 $site3", like => '/Moving site '.$site2.' to '.$site3.'.../' },
  { cmd => $omd_bin." rm $site3",        like => '/Restarting Apache...OK/', stdin => "yes\n" },
  { cmd => $omd_bin." rm $site",         like => '/Restarting Apache...OK/', stdin => "yes\n" },
];

# run tests
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}
