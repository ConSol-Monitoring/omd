#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

plan( tests => 64 );

##################################################
# create our test site
my $site = TestUtils::create_test_site() or BAIL_OUT("no further testing without site");

##################################################
# execute some checks
my $tests = [
  { cmd => "/usr/bin/omd start $site" },

  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -u /$site/thruk -e 401'",                    exp => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/thruk -e 301'",    exp => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/thruk/ -e 200'",   exp => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u \"/$site/thruk/cgi-bin/status.cgi?hostgroup=all&style=hostdetail\" -e 200 -r \"Host Status Details For All Host Groups\"'", exp => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u \"/$site/thruk/cgi-bin/tac.cgi\" -e 200 -r \"Logged in as <i>omdadmin<\/i>\"'", exp => '/HTTP OK:/' },

  { cmd => "/usr/bin/omd stop $site" },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}

# switch webserver to shared mode
TestUtils::test_command({ cmd => "/usr/bin/omd config $site set WEBSERVER shared" });
TestUtils::test_command({ cmd => "/etc/init.d/apache2 reload" });

# then run tests again
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}

##################################################
# cleanup test site
TestUtils::remove_test_site($site);