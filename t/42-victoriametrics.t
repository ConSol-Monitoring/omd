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

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

TestUtils::test_command({ cmd => $omd_bin." config $site set THRUK_COOKIE_AUTH off" });
TestUtils::test_command({ cmd => $omd_bin." config $site set CORE none" });
TestUtils::test_command({ cmd => $omd_bin." config $site set GRAFANA on" });
TestUtils::test_command({ cmd => $omd_bin." config $site set VICTORIAMETRICS on" });
TestUtils::test_command({ cmd => $omd_bin." start $site", like => ['/Starting victoriametrics\.+OK/',
                                                                   '/Starting Grafana\.+OK/',
                                                                  ]});

TestUtils::test_command({ cmd => qq[/bin/su - $site -c 'victoria-metrics-prod --version'],  like => '/^victoria-metrics/' });
TestUtils::test_command({ cmd => qq[/bin/su - $site -c 'vmagent-prod --version'],  like => '/^vmagent/' });
TestUtils::test_command({ cmd => qq[/bin/su - $site -c 'vmauth-prod --version'],  like => '/^vmauth/' });
TestUtils::test_command({ cmd => qq[/bin/su - $site -c 'vmbackup-prod --version'],  like => '/^vmbackup/' });
TestUtils::test_command({ cmd => qq[/bin/su - $site -c 'vmalert-prod --version'],  like => '/^vmalert/' });
TestUtils::test_command({ cmd => qq[/bin/su - $site -c 'vmctl --version'],  like => '/vmctl version/', errlike => '/^/' });
TestUtils::test_command({
  cmd => qq[/bin/su - $site -c 'lib/monitoring-plugins/check_http ].
         qq[-t 60 -H 127.0.0.1 -p 8428 --onredirect=follow -u "/metrics" -s "vm_app_version"'],
  like => '/HTTP OK:/',
  waitfor => 'HTTP\ OK:',
});
TestUtils::remove_test_site($site);
done_testing();
__END__
