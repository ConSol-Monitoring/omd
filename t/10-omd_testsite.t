#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

plan( tests => 132 );

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

  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -u /$site -e 401'",          exp => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -u /$site/omd -e 401'",      exp => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -u /$site/nagios -e 401'",   exp => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -u /$site/check_mk -e 401'", exp => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -u /$site/nagvis -e 401'",   exp => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -u /$site/wiki -e 401'",     exp => '/HTTP OK:/' },

  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site -e 302'",          exp => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/omd -e 301'",      exp => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/nagios -e 301'",   exp => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/check_mk -e 301'", exp => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/nagvis -e 301'",   exp => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/wiki -e 301'",     exp => '/HTTP OK:/' },

  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/omd/ -e 200'",         exp => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/nagios/ -e 200'",      exp => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/check_mk/ -e 200'",    exp => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/nagvis/ -e 302'",      exp => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/nagvis/frontend/nagvis-js/index.php -e 302'", exp => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/wiki/ -e 302'",        exp => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/wiki/doku.php -e 200'",exp => '/HTTP OK:/' },

  { cmd => "/usr/bin/omd stop $site",       exp => '/Stopping nagios:/' },
  { cmd => "/usr/bin/omd cp $site $site2",  exp => '/Cping site '.$site.' to '.$site2.'.../' },
  { cmd => "/usr/bin/omd mv $site2 $site3", exp => '/Mving site '.$site2.' to '.$site3.'.../' },
  { cmd => "/usr/bin/omd rm $site3",        exp => '/Restarting Apache...OK/', stdin => "yes\n" },
  { cmd => "/usr/bin/omd rm $site",         exp => '/Restarting Apache...OK/', stdin => "yes\n" },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}
