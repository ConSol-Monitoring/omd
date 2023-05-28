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
    use BuildHelper;
}

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

##################################################
# execute some checks
my $tests = [
  { cmd => "/bin/su - $site -c 'omd start'", like => '/Starting/' },
  { cmd => "/bin/su - $site -c '/usr/bin/env node -v'", like => '/^v/' },
  { cmd => "/bin/su - $site -c '/usr/bin/env npm -v'",  like => '/^\d/' },
  { cmd => "/bin/su - $site -c '/usr/bin/env NODE_PATH=lib/node_modules node share/thruk/script/puppeteer.js http://localhost:5000/ test.png 200 200 000'" },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test) || diag(`/usr/bin/env; /bin/su - $site -c '/usr/bin/env'`);
}

##################################################
# cleanup test site
TestUtils::remove_test_site($site);

done_testing();
