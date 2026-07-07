#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

########################################
# print node version
my $ntest = { cmd => "/bin/su - $site -c 'node -v'", like => '/^v/' };
TestUtils::test_command($ntest) or TestUtils::bail_out_clean("no further testing without working node");
diag("Node: ".$ntest->{'stdout'});
ok($ntest, "has node version");

########################################
# print npm version
$ntest = { cmd => "/bin/su - $site -c 'npm -v'", like => '/^\d/' };
TestUtils::test_command($ntest) or TestUtils::bail_out_clean("no further testing without working npm");
diag("NPM: ".$ntest->{'stdout'});
ok($ntest, "has npm version");

########################################
# print chrome version
my $ctest = { cmd => "/bin/su - $site -c 'echo ".'$PUPPETEER_EXECUTABLE_PATH'."'" };
TestUtils::test_command($ctest) or TestUtils::bail_out_clean("no further testing without working chrome");
chomp($ctest->{'stdout'});
#diag("Chrome: ".$ctest->{'stdout'});
ok($ntest, "has chrome executable path");
my $vtest = { cmd => "/bin/su - $site -c '".$ctest->{'stdout'}." --version'" };
TestUtils::test_command($vtest) or TestUtils::bail_out_clean("no further testing without working chrome");
chomp($vtest->{'stdout'});
diag($vtest->{'stdout'}." (".$ctest->{'stdout'}.")");
ok($ntest, "has chrome version");

##################################################
# execute some checks
my $tests = [
  { cmd => "/bin/su - $site -c 'omd start'", like => '/Starting/' },
  { cmd => "/bin/su - $site -c '/usr/bin/env NODE_PATH=lib/node_modules node share/thruk/script/puppeteer.js http://localhost:5000/".$site."/thruk/cgi-bin/remote.cgi test.png 200 200 000'" },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test) || diag(`/usr/bin/env; /bin/su - $site -c '/usr/bin/env'`);
}

##################################################
# cleanup test site
TestUtils::remove_test_site($site);

done_testing();
