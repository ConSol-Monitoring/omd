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

plan( tests => 86 );

##################################################
# create our test site
my $omd_bin   = TestUtils::get_omd_bin();
my $site      = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

TestUtils::test_command({ cmd => "/bin/su - $site -c 'cp share/doc/naemon/example.cfg etc/naemon/conf.d/'", like => '/^$/' });

# remove victoriametrics auth via empty config file:
TestUtils::test_command({ cmd => qq{/bin/su - $site -c "echo '# dummy config' > ~$site/etc/victoriametrics/conf.d/auto_auth.conf" }, errlike => '/^$/'});

TestUtils::test_command({ cmd => $omd_bin." stop $site " , like => '/Stopp.*OK/' });

TestUtils::test_command({ cmd => $omd_bin." config $site set VICTORIAMETRICS on" });
TestUtils::test_command({ cmd => $omd_bin." config $site set PNP4NAGIOS off" });
TestUtils::test_command({ cmd => $omd_bin." config $site set NAGFLUX on" });
TestUtils::test_command({ cmd => $omd_bin." config $site set CORE naemon" });
TestUtils::test_command({ cmd => $omd_bin." config $site set MOD_GEARMAN on" });
TestUtils::test_command({ cmd => $omd_bin." config $site set GEARMAND on" });

# enable perfdata over gearman
TestUtils::test_command({ cmd => "/usr/bin/env sed -e 's/^config=.*perfdata.*/perfdata=nagflux/' -i ~$site/etc/mod-gearman/server.cfg"});
TestUtils::test_command({ cmd => "/bin/su - $site -c '> etc/nagflux/nagios_nagflux.cfg'"});
TestUtils::test_command({ cmd => "/usr/bin/env sed -e '/^\\[ModGearman .example.\\]/,/^\\[/{s%^\\(\\s*Enabled\\).*%\\1 = true %}' -i ~$site/etc/nagflux/config.gcfg"});
TestUtils::test_command({ cmd => "/usr/bin/env sed -e 's/Queue = .*/Queue = nagflux/' -i ~$site/etc/nagflux/config.gcfg"});
TestUtils::test_command({ cmd => "/usr/bin/env sed -e 's/-pnp/-perf/' -i ~$site/etc/naemon/conf.d/example.cfg"});

# switch target to victoriametrics
TestUtils::test_command({ cmd => "/usr/bin/env sed -e '/^\\[InfluxDB .nagflux.\\]/,/^\\[/{s%^\\(\\s*Enabled\\).*%\\1 = false %}' -i ~$site/etc/nagflux/config.gcfg"});
TestUtils::test_command({ cmd => "/usr/bin/env sed -e '/^\\[InfluxDB .victoriametrics.\\]/,/^\\[/{s%^\\(\\s*Enabled\\).*%\\1 = true %}' -i ~$site/etc/nagflux/config.gcfg"});

# enable nagflux logging:
TestUtils::test_command({ cmd => "/usr/bin/env sed -e 's/\\(\\s*MinSeverity\\).*/\\1 = \"DEBUG\"/' -i ~$site/etc/nagflux/config.gcfg"});

TestUtils::test_command({ cmd => $omd_bin." start $site", like => '/Starting nagflux\.+OK/' });

# reschedule checks
TestUtils::test_command({ cmd => "/bin/su - $site -c './share/thruk/support/reschedule_all_checks.sh'", like => '/COMMAND/' });

#Test if database is up
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -t 60 -H 127.0.0.1 -p 8428 -u \"/health\"  '", like => '/HTTP OK:/', waitfor => 'HTTP\ OK:', maxwait => 180 });

# see if nagflux queue exists
TestUtils::test_command({ cmd => "/bin/su - $site -c 'gearman_top -b'", like => '/nagflux/', waitfor => "nagflux" });

# spool folder should be empty
TestUtils::test_command({ cmd => "/bin/su - $site -c 'ls var/pnp4nagios/spool/'", like => '/^$/' });

# wait until all data is inserted: 20
TestUtils::test_url({
    url            => "http://127.0.0.1:8428/api/v1/query?query=count(metrics_value{host=\"localhost\"})",
    like           => [ "/.*value.*/" ],
    waitfor        => ".*value\":",
    maxwait        => 180,
});

#Clean up
TestUtils::remove_test_site($site);
