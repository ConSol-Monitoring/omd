#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use POSIX;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
    use FindBin;
    use lib "$FindBin::Bin/lib/lib/perl5";
}

plan( tests => 75 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

##################################################
# execute some checks
my $tests = [
  { cmd => $omd_bin." config $site set MYSQL on" },
  { cmd => $omd_bin." config $site show MYSQL",  like => '/on/', 'unlike' => [ '/error/', '/off/' ] },
  { cmd => $omd_bin." start  $site" },
  { cmd => $omd_bin." status $site",             like => '/mysql:\s*running/' },
  { cmd => "/bin/su - $site -c 'mysql mysql'", stdin => "show tables;\n", like => [ '/user/', '/tables_priv/' ] },
  { cmd => $omd_bin." stop   $site" },
  { cmd => $omd_bin." config $site set THRUK_LOGCACHE on" },
  { cmd => "/bin/su - $site -c 'rm etc/cron.d/thruk_logcache.auto'", like => [ '/^$/' ] }, # might already run otherwise
  { cmd => $omd_bin." start  $site" },
  { cmd => "/bin/su - $site -c 'thruk logcache import -y -q'", like => [ '/imported \d+ log items from 1 site successfully/' ] },
  { cmd => "/bin/su - $site -c 'mysql thruk_logs'", stdin => "show tables;\n", like => [ '/_status/', '/_log/' ] },
  { cmd => "/bin/su - $site -c 'thruk logcache update -q'", like => [ '/log items from 1 site successfully in/' ] },
  { cmd => "/bin/su - $site -c './share/thruk/examples/get_logs ./var/naemon/naemon.log'", like => '/^$/' },
  { cmd => "/bin/su - $site -c './share/thruk/examples/get_logs -n ./var/naemon/naemon.log'", like => '/^$/' },
  { cmd => "/bin/su - $site -c 'thruk logcache drop -y -q'", like => [ '/OK - droped logcache for/' ] },
  { cmd => "/bin/su - $site -c 'mysql thruk_logs'", stdin => "show tables;\n", like => [ '/^$/' ] },
  { cmd => $omd_bin." stop   $site" },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}

##################################################
# cleanup test site
TestUtils::remove_test_site($site);
