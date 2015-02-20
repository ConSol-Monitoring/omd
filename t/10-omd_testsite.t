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

plan( tests => 159 );

my $omd_bin = TestUtils::get_omd_bin();

# print omd version
my $vtest = { cmd => $omd_bin." version", "exit" => undef };
TestUtils::test_command($vtest) or TestUtils::bail_out_clean("no further testing without working omd");
diag($vtest->{'stdout'});

########################################
# execute some commands
my $site  = 'testsite';
my $site2 = 'testsite2';
my $site3 = 'testsite3';
my $tests = [
  { cmd => $omd_bin." versions",     like => '/^\d+\.\d+( \(default\))?/'  },
  { cmd => $omd_bin." rm $site",     stdin => "yes\n", 'exit' => undef, errlike => undef },
  { cmd => $omd_bin." rm $site2",    stdin => "yes\n", 'exit' => undef, errlike => undef },
  { cmd => $omd_bin." rm $site2",    stdin => "yes\n", 'exit' => undef, errlike => undef },
  { cmd => $omd_bin." create $site", like => '/Created new site '.$site.'./' },
  { cmd => $omd_bin." sites",        like => '/^'.$site.'\s+\d+\.\d+( \(default\))?/m' },
  { cmd => "/bin/df -k /omd/sites/$site/tmp/.", like => '/tmpfs/m' },
  { cmd => $omd_bin." start $site",  like => '/Starting naemon/' },
  { cmd => $omd_bin." status $site", like => [
                                                '/apache:\s*running/',
                                                '/rrdcached:\s*running/',
                                                '/npcd:\s*running/',
                                                '/naemon:\s*running/',
                                                '/Overall state:\s*running/',
                                               ]
  },
  { cmd => $omd_bin." stop $site",       like => '/Stopping naemon/' },
  { cmd => $omd_bin." cp $site $site2",  like => '/Copying site '.$site.' to '.$site2.'.../', 
                                         errlike => '/Apache port \d+ is in use\. I\'ve choosen \d+ instead\./' },
  { cmd => "/usr/bin/find /omd/sites/$site2/ -not -user $site2 -ls",  like => '/^\s*$/' },
  { cmd => "/bin/df -k /omd/sites/$site2/tmp/.", like => '/tmpfs/m' },
  { cmd => $omd_bin." mv $site2 $site3", like => '/Moving site '.$site2.' to '.$site3.'.../' },
  { cmd => "/usr/bin/find /omd/sites/$site3/ -not -user $site3 -ls",  like => '/^\s*$/' },
  { cmd => "/bin/df -k /omd/sites/$site3/tmp/.", like => '/tmpfs/m' },
  { cmd => $omd_bin." rm $site3",        like => '/Restarting Apache...\s*OK/', stdin => "yes\n" },
  { cmd => $omd_bin." rm $site",         like => '/Restarting Apache...\s*OK/', stdin => "yes\n" },
  { cmd => $omd_bin." create -u 7017 -g 7018 $site", 
                                         like => '/Created new site '.$site.'./' },
  { cmd => "/usr/bin/id -u $site",       like => '/7017/' },
  { cmd => "/usr/bin/id -g $site",       like => '/7018/' },
  { cmd => $omd_bin." cp -u 7019 -g 7020 $site $site2", 
                                         like => '/Copying site '.$site.' to '.$site2.'.../', 
                                         errlike => '/Apache port \d+ is in use\. I\'ve choosen \d+ instead\./' },
  { cmd => "/usr/bin/id -u $site2",      like => '/7019/' },
  { cmd => "/usr/bin/id -g $site2",      like => '/7020/' },
  { cmd => $omd_bin." mv -u 7021 -g 7022 $site2 $site3", like => '/Moving site '.$site2.' to '.$site3.'.../' },
  { cmd => "/usr/bin/id -u $site3",      like => '/7021/' },
  { cmd => "/usr/bin/id -g $site3",      like => '/7022/' },
  { cmd => $omd_bin." rm $site",         like => '/Restarting Apache...\s*OK/', stdin => "yes\n" },
  { cmd => $omd_bin." rm $site3",        like => '/Restarting Apache...\s*OK/', stdin => "yes\n" },

  # --reuse
  { cmd => $omd_bin." create $site", like => '/Created new site '.$site.'./' },
  { cmd => $omd_bin." rm --reuse $site", stdin => "yes\n" },
  { cmd => "/usr/bin/id -u $site",       like => '/\d+/' },
  { cmd => "/usr/bin/id -g $site",       like => '/\d+/' },
  { cmd => $omd_bin." create $site2",    like => '/Created new site '.$site2.'./', errlike => '/ERROR: Failed to read config of site testsite./' },
  { cmd => $omd_bin." mv --reuse $site2 $site", like => '/Moving site '.$site2.' to '.$site.'.../' , errlike => '/ERROR: Failed to read config of site testsite./' },
  { cmd => "/usr/bin/id -u $site2",      like => '/\d+/' },
  { cmd => "/usr/bin/id -g $site2",      like => '/\d+/' },
  { cmd => $omd_bin." cp --reuse $site $site2",  like => '/Copying site '.$site.' to '.$site2.'.../',
                                         errlike => '/Apache port \d+ is in use\. I\'ve choosen \d+ instead\./' },
  { cmd => $omd_bin." cp --reuse $site $site2", errlike => '/must be empty/', exit => 1 },
  { cmd => $omd_bin." rm $site",         like => '/Restarting Apache...\s*OK/', stdin => "yes\n" },
  { cmd => $omd_bin." rm $site2",        like => '/Restarting Apache...\s*OK/', stdin => "yes\n" },
];

# run tests
for my $test (@{$tests}) {
    TestUtils::test_command($test) or TestUtils::bail_out_clean("no further testing without working omd");
}
