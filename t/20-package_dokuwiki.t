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

plan( skip_all => "dokowiki requires at least php 7.4" ) if $php_version < 7.4;

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");
my $auth    = 'OMD Monitoring Site '.$site.':omdadmin:omd';

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

# create session cookie
TestUtils::test_command({ cmd => $omd_bin." stop $site" });
my $sessionid = TestUtils::create_fake_cookie_login($site);
TestUtils::test_command({ cmd => $omd_bin." config $site set THRUK_COOKIE_AUTH on", like => '/^$/' });
TestUtils::test_command({ cmd => $omd_bin." start $site", like => '/Starting apache/' });
TestUtils::set_cookie("thruk_auth", $sessionid, time() + 3600);

TestUtils::test_url({ 
    url              => 'http://localhost/'.$site.'/wiki/doku.php', 
    auth             => $auth, 
    like             => ["/Welcome to your Dokuwiki/", "/Logged in as:.*<bdi>omdadmin/s", "/Admin/"],
    unlike           => ["/internal error/", "/NOTOC/", "/NOCACHE/", "/====/"],
    skip_html_lint   => 1,
    skip_link_check  => ['.*'],
});

##################################################
# cleanup test site
TestUtils::test_command({ cmd => $omd_bin." stop $site" });
TestUtils::remove_test_site($site);

done_testing();
