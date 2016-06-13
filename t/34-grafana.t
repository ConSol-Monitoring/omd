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

plan( tests => 48 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");
my $auth    = 'OMD Monitoring Site '.$site.':omdadmin:omd';

TestUtils::test_command({ cmd => $omd_bin." config $site set GRAFANA on" });
TestUtils::test_command({ cmd => $omd_bin." start $site", like => '/Starting Grafana...OK/' });

#grafana interface
TestUtils::test_url({ url => 'http://localhost/'.$site.'/grafana/', waitfor => '<title>Grafana<\/title>', auth => $auth });
TestUtils::test_url({ url => 'http://localhost/'.$site.'/grafana/', auth => $auth, like => [ '/"login":"omdadmin"/', '/"isSignedIn":true/' ], unlike => ['/\(null\)/'], skip_html_lint => 1 });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 60 -H localhost -p 8003 -k \"X-WEBAUTH-USER: omdadmin\" -s \"<title>Grafana</title>\"'", like => '/HTTP OK:/' });

#grafana interface with ssl
TestUtils::test_command({ cmd => $omd_bin." stop $site", like => '/Stopping Grafana/' });
TestUtils::test_command({ cmd => $omd_bin." config $site set APACHE_MODE ssl", like => '/^$/' });
TestUtils::test_command({ cmd => $omd_bin." start $site", like => '/Starting Grafana/' });
TestUtils::restart_system_apache();
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 60 -H localhost -S -a omdadmin:omd -u \'/$site/grafana/\' -s \\\"login\\\":\\\"omdadmin\\\"'", like => '/HTTP OK:/' });

TestUtils::test_command({ cmd => $omd_bin." stop $site" });
TestUtils::remove_test_site($site);

