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

plan( tests => 104 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

# not started site should give a nice error
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -H localhost -u /$site -e 503 -r \"OMD: Site Not Started\"'",  like => '/HTTP OK:/' });

##################################################
# execute some checks
my $tests = [
  { cmd => $omd_bin." start $site" },

  { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -H localhost -u /$site -e 302'",                      like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -H localhost -u /$site/ -e 302'",                     like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -H localhost -u /$site/omd -e 302'",                  like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -H localhost -a omdadmin:omd -u /$site -e 302'",      like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -H localhost -a omdadmin:omd -u /$site/omd -e 301,302'",  like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -H localhost -a omdadmin:omd -u /$site/omd/ -e 302'", like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -H localhost -a omdadmin:omd -u /$site/omd/vierhundertvier -e 404'", like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -H localhost -u /$site/omd/vierhunderteins -e 401'", like => '/HTTP OK:/' },

  { cmd => $omd_bin." stop $site" },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}

TestUtils::test_command({ cmd => "/bin/su - $site -c 'omd config set APACHE_MODE ssl'",  like => '/^$/' });
TestUtils::restart_system_apache();
TestUtils::test_command({ cmd => "/bin/su - $site -c 'omd start'",  like => '/Starting dedicated Apache.*?OK/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -H localhost -S -a omdadmin:omd -u /$site/thruk/startup.html -e 200 -vvv'", like => ['/HTTP OK:/', '/Please stand by, Thruks FastCGI Daemon is warming/'] });

TestUtils::test_command({ cmd => "/bin/su - $site -c 'omd stop'",  like => '/Stopping dedicated Apache/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'omd config set THRUK_COOKIE_AUTH on'",  like => '/^$/' });

# omd diff should list no files after creating a site, otherwise hooks are wrong and create lots of conflicts on every update
{
    my $test = { cmd => $omd_bin." diff $site",     unlike => '/Changed content/', like => '/^$/' };
    TestUtils::test_command($test);
    my @failed = $test->{'stdout'} =~ m|^\s*\*\s+Changed\s+content\s+(.*)$|gmx;
    for my $file (@failed) {
        diag($file);
        my $test = { cmd => $omd_bin." diff $site $file" };
        TestUtils::test_command($test);
        diag($test->{'stdout'});
    }
}
TestUtils::test_command({ cmd => "/bin/su - $site -c 'omd config set THRUK_COOKIE_AUTH off'",  like => '/^$/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'omd start'",  like => '/Starting dedicated Apache.*?OK/' });

########
# call dacretain
TestUtils::test_command({ cmd => "/bin/su - $site -c 'dacretain save_livestatus'", exit => 0, errlike => ['/dacretain: init_db/', '/dacretain: save_livestatus/'] });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'test -f var/dacretain.db'", exit => 0 });

##################################################
# test if nagios cgis are no longer in place
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -H localhost -S -a omdadmin:omd -u /$site/nagios/images/logos/debian.png -e 200 -v'", like => ['/HTTP OK:/', '/png/'] });

##################################################
TestUtils::test_command({ cmd => "/bin/su - $site -c 'omd stop'",  like => '/Stopping dedicated Apache/' });

##################################################
# cleanup test site
TestUtils::remove_test_site($site);
