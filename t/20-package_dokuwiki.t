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

my $php_version = `php -v`;
$php_version =~ s%^PHP\ (\d\.\d).*%$1%gmsx;
plan( skip_all => 'dokuwiki requires at least php 5.6') if $php_version < 5.6;
plan( tests => 39 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

##################################################
# execute some checks
my $tests = [
  { cmd => $omd_bin." start $site" },

  { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -H localhost -u /$site/wiki -e 401'",                          like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -H localhost -a omdadmin:omd -u /$site/wiki -e 301'",          like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -H localhost -a omdadmin:omd -u /$site/wiki/ -e 302'",         like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -H localhost -a omdadmin:omd -u /$site/wiki/doku.php -e 200'", like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -H localhost -a omdadmin:omd -u \"/$site/wiki/doku.php?id=start&do=export_pdf\" -e 200'", like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'test -h var/dokuwiki/lib/plugins/acl'", like => '/^\s*$/' },

  { cmd => $omd_bin." stop $site" },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}

##################################################
# cleanup test site
TestUtils::remove_test_site($site);
