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
  { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -H localhost -a omdadmin:omd -u \"/$site/wiki/doku.php?id=start&do=export_pdf\" -e 200 -t 60'", like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'test -h var/dokuwiki/lib/plugins/acl'", like => '/^\s*$/' },

];
for my $test (@{$tests}) {
    if($php_version < 5.6 && $test->{'cmd'} =~ m/export_pdf/) {
        diag('dokuwiki pdf export requires at least php 5.6') ;
        next;
    }
    TestUtils::test_command($test);
}

##################################################
# cleanup test site
TestUtils::test_command({ cmd => $omd_bin." stop $site" });
TestUtils::remove_test_site($site);

done_testing();
