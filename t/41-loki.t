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

plan( tests => 68 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

TestUtils::test_command({ cmd => "/usr/bin/env sed -i -e 's/^#use_lmd_core=1/use_lmd_core=1/g' /opt/omd/sites/$site/etc/thruk/thruk_local.d/lmd.conf" });
TestUtils::test_command({ cmd => "/usr/bin/env sed -i -e 's/# LogLevel = \"Warn\"/LogLevel = \"Debug\"/g' /opt/omd/sites/$site/etc/thruk/lmd.ini" });
TestUtils::test_command({ cmd => $omd_bin." config $site set LOKI on" });
TestUtils::test_command({ cmd => $omd_bin." config $site set LOKI_PROMTAIL on" });
TestUtils::test_command({ cmd => $omd_bin." start $site", like => ['/Starting loki\.+OK/',
                                                                   '/Starting promtail\.+OK/',
                                                                  ]});
TestUtils::test_command({ cmd => $omd_bin." status $site", like => ['/loki:\s+running/',
                                                                    '/promtail:\s+running/',
                                                                  ]});

# trigger error in thruk.log
TestUtils::test_command({ cmd => "/bin/su - $site -c 'curl -s -u omdadmin:omd \"http://127.0.0.1/$site/thruk/cgi-bin/test.cgi\"'", like => '/Stacktrace:/' });


TestUtils::test_command({
    cmd     => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -t 60 -H 127.0.0.1 -p 3100 -u \"/loki/api/v1/label\" -s \"filename\" -vv'",
    waitfor => 'HTTP\ OK',
    like    => '/HTTP OK:/',
});

# test if we got all expected logfiles
TestUtils::test_command({
    cmd     => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -t 60 -H 127.0.0.1 -p 3100 -u \"/loki/api/v1/label/filename/values\" -s \"error_log\" -vv'",
    waitfor => 'HTTP\ OK',
    like    => ['/HTTP OK:/',
                '/naemon.log/',
                '/apache\/access_log/',
                '/lmd.log/',
                '/thruk.log/',
               ],
});
# check naemon expression parser
TestUtils::test_command({
    cmd     => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -t 60 -H 127.0.0.1 -p 3100 -u \"/loki/api/v1/label/type/values\" -s \"nerd\" -vv'",
    waitfor => 'HTTP\ OK',
    like    => ['/HTTP OK:/',
                '/LOG VERSION/',
                '/TIMEPERIOD TRANSITION/',
               ],
});

# check thruk expression parser
TestUtils::test_command({
    cmd     => "/bin/su - $site -c 'curl -G --data-urlencode \"query={filename=~\\\".*/thruk.log\\\", severity=\\\"error\\\"}\" -s http://127.0.0.1:3100/loki/api/v1/query_range'",
    like    => [
                '/Thruk\/Controller\/test\.pm/',
                '/test.cgi is disabled/',
                '/omdadmin/',
               ],
});

# check apache expression parser
TestUtils::test_command({
    cmd     => "/bin/su - $site -c 'curl -G --data-urlencode \"query={filename=~\\\".*/error_log\\\", severity=\\\"notice\\\"}\" -s http://127.0.0.1:3100/loki/api/v1/query_range'",
    like    => [
                '/apache_module/',
                '/apache_log/',
                '/mod_fcgid/',
               ],
});

# cleanup
TestUtils::remove_test_site($site);
