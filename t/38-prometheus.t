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

plan( tests => 104 );


##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

TestUtils::test_command({ cmd => $omd_bin." config $site set THRUK_COOKIE_AUTH off" });
TestUtils::test_command({ cmd => $omd_bin." config $site set CORE none" });
TestUtils::test_command({ cmd => $omd_bin." config $site set PROMETHEUS on" });
TestUtils::test_command({ cmd => $omd_bin." config $site set GRAFANA on" });
TestUtils::test_command({ cmd => $omd_bin." config $site set PROMETHEUS_TCP_PORT 10000" });
TestUtils::test_command({ cmd => $omd_bin." config $site set PROMETHEUS_TCP_ADDR 127.0.0.2" });
TestUtils::test_command({ cmd => $omd_bin." config $site set BLACKBOX_EXPORTER on" });
TestUtils::test_command({ cmd => $omd_bin." config $site set ALERTMANAGER on" });
TestUtils::test_command({ cmd => $omd_bin." start $site", like => ['/Starting prometheus\.+OK/',
                                                                   '/Starting blackbox_exporter\.+OK/',
                                                                   '/Starting alertmanager\.+OK/',
                                                                   '/Starting Grafana\.+OK/',
                                                                  ]});
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -t 60 -H 127.0.0.1 --onredirect=follow -a omdadmin:omd -u \"/$site/prometheus\" -s \"<title>Prometheus Time Series Collection and Processing Server</title>\"'", like => '/HTTP OK:/', waitfor => 'OK:', maxwait => 180 });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -t 60 -H 127.0.0.1 --onredirect=follow -a omdadmin:omd -u \"/$site/alertmanager\" -s \"<title>Alertmanager</title>\"'", like => '/HTTP OK:/', waitfor => 'OK:' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -t 60 -H 127.0.0.1 -p 9115 -u \"/metrics\" -s \"process_open_fds\"'", like => '/HTTP OK:/' });
my $blackbox_icmp = TestUtils::test_command({ cmd => qq[/bin/su - $site -c 'lib/monitoring-plugins/check_http -t 60 -H 127.0.0.1 -p 9115 -u "/probe?module=icmp&target=127.0.0.1" -s "probe_success 1"'], like => '/HTTP OK:/' });
unless($blackbox_icmp) {
    local $ENV{PATH} = "/usr/sbin:/sbin:$ENV{PATH}";
    my $be = '/opt/omd/versions/default/bin/blackbox_exporter';
    diag(qx(sysctl net.ipv4.ping_group_range));
    diag(qx(printf '%s(%s): ' capabilities $be; getcap $be));
};
# grafana can take some time to start it's webserver
TestUtils::test_command({ cmd => "/bin/su - $site -c 'cat var/log/grafana/grafana.log'", like => '/HTTP Server Listen/', waitfor => 'HTTP\ Server\ Listen', maxwait => 180 });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -t 60 -H 127.0.0.1 --onredirect=follow -a omdadmin:omd -u \"/$site/grafana/api/datasources/proxy/2/api/v1/query_range?query=go_goroutines&start=1535520675&end=1535542290&step=15\" -s \"success\"'", like => '/HTTP OK:/', waitfor => 'OK:' });

# test reload
TestUtils::test_command({ cmd => "/bin/su - $site -c 'omd reload prometheus'" });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'tail -10 var/prometheus/prometheus.log| grep loading'", like => '/Completed loading of configuration file/', errlike => '/^$/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'tail -100 var/prometheus/prometheus.log| grep -v -q SIGTERM'"  });

TestUtils::test_command({ cmd => "/bin/su - $site -c 'omd reload alertmanager'" });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'tail -5 var/alertmanager/alertmanager.log| grep loading'", like => '/Completed loading of configuration file/', errlike => '/^$/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'tail -5 var/alertmanager/alertmanager.log| grep -v -q SIGTERM'"  });

# test removed datasource for grafana:
TestUtils::test_command({ cmd => $omd_bin." stop $site" });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'mv etc/prometheus/grafana_datasources.yml etc/prometheus/grafana_datasources_ignore.yml'", errlike => '/^$/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'ls -l etc/grafana/provisioning/datasources/'", like => ['/prometheus.yml/']});
# with check config the hook removes the link to missing file
TestUtils::test_command({ cmd => $omd_bin." config $site set PROMETHEUS on ", errlike => '/^$/'});
TestUtils::test_command({ cmd => "/bin/su - $site -c 'ls -l etc/grafana/provisioning/datasources/prometheus.yml'", exit => 2, errlike => '/No such file or directory/' });


# cleanup
TestUtils::remove_test_site($site);
