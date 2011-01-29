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

plan( tests => 82 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or BAIL_OUT("no further testing without site");
my $auth    = 'OMD Monitoring Site '.$site.':omdadmin:omd';

#TestUtils::test_command({ cmd => "/d1/nagvis/mache" });

# set nagvis as default
TestUtils::test_command({ cmd => $omd_bin." config $site set WEB nagvis" });
TestUtils::test_command({ cmd => $omd_bin." start $site" });

##################################################
# execute some checks
my $tests = [
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -u /$site/nagvis -e 401'",                  like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/nagvis -e 301'",  like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/nagvis/ -e 302'", like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -H localhost -a omdadmin:omd -u /$site/nagvis/frontend/nagvis-js/index.php -e 302'", like => '/HTTP OK:/' },
];

for my $test (@{$tests}) {
    TestUtils::test_command($test);
}

##################################################
# URL tests

my $urls = [
  # OMD welcome page in NagVis mode
  { url => "", like => '/<title>NagVis .*<\/title>/' },

	# default pages
  { url => "/nagvis/frontend/nagvis-js/index.php",                             like => '/<title>NagVis .*<\/title>/' },
  { url => "/nagvis/frontend/wui/index.php",                                   like => [ '/<title>NagVis .+ &rsaquo; WUI<\/title>/',
	                                                                                       '/Welcome to the NagVis WUI/' ] },
  { url => "/nagvis/frontend/nagvis-js/index.php?mod=Info",                    like => '/NagVis Support Information<\/title>/' },
  { url => "/nagvis/frontend/nagvis-js/index.php?mod=Map&act=view&show=demo",  like => '/, \'demo\'/' },
  { url => "/nagvis/frontend/wui/index.php?mod=Map&act=edit&show=demo",        like => [ '/WUI<\/title>/', '/var mapname = \'demo\';/' ] },

	# Old redirects to maps
  { url => "/nagvis/index.php?map=demo",       like => '/, \'demo\'/' },
  { url => "/nagvis/config.php?map=demo",      like => [ '/WUI<\/title>/', '/var mapname = \'demo\';/' ] },
];

# complete the url and perform tests
for my $url ( @{$urls} ) {
    $url->{'url'} = "http://localhost/".$site.$url->{'url'};
    $url->{'auth'}   = $auth;
    $url->{'unlike'} = [ '/internal server error/' ];

    TestUtils::test_url($url);
}

##################################################
# cleanup test site
TestUtils::remove_test_site($site);
