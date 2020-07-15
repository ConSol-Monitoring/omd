#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use Sys::Hostname;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
    use FindBin;
    use lib "$FindBin::Bin/lib/lib/perl5";
}

plan( tests => 41 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

TestUtils::test_command({ cmd => $omd_bin." config $site set THRUK_COOKIE_AUTH off" });
TestUtils::test_command({ cmd => $omd_bin." config $site set CORE none" });
TestUtils::test_command({ cmd => $omd_bin." config $site set LOKI on" });
TestUtils::test_command({ cmd => $omd_bin." config $site set LOKI_PROMTAIL on" });
TestUtils::test_command({ cmd => $omd_bin." start $site", like => ['/Starting Loki\.+OK/',
                                                                   '/Starting Promtail\.+OK/',
                                                                  ]});
TestUtils::test_command({ cmd => $omd_bin." status $site", like => ['/loki:\s+running/',
                                                                    '/promtail:\s+running/',
                                                                  ]});
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -t 60 -H 127.0.0.1 -p 3100 -u \"/loki/api/v1/label\" -s \"filename\" -vv'", like => '/HTTP OK:/', waitfor => 'HTTP\ OK' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -t 60 -H 127.0.0.1 -p 3100 -u \"/loki/api/v1/label/filename/values\" -s \"error_log\" -vv'", like => '/HTTP OK:/', waitfor => 'HTTP\ OK' });

# cleanup
TestUtils::remove_test_site($site);

