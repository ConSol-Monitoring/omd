#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use utf8;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

plan( tests => 171 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

TestUtils::install_test_checks($site);

##################################################
# execute some checks
my $tests = [
  { cmd => $omd_bin." config $site set CORE naemon" },

  { cmd => "/bin/su - $site -c 'cp share/doc/naemon/example.cfg etc/naemon/conf.d/'", like => '/^$/' },
  { cmd => "/bin/su - $site -c 'omd check naemon'", like => '/Running configuration check\.+\s*done/', errlike => '/Things look okay/', fatal => 1 },
  { cmd => $omd_bin." start $site" },

  { cmd => "/bin/su - $site -c 'test -S tmp/run/live'", like => '/^$/' },
  { cmd => "/bin/su - $site -c 'test -p tmp/run/naemon.cmd'", like => '/^$/' },
  { cmd => "/bin/su - $site -c 'test -f var/naemon/livestatus.log'", like => '/^$/' },

  { cmd => "/bin/su - $site -c './share/thruk/support/reschedule_all_checks.sh'", like => '/COMMAND/' },
  { cmd => "/bin/su - $site -c 'echo \"COMMAND [".time()."] SCHEDULE_FORCED_SVC_CHECK;localhost;check_locale.py;".time()."\" | lq'", like => '/^\s*$/' },

  # wait for all checks completed
  { cmd => "/bin/su - $site -c 'thruk r \"/services?columns=has_been_checked&has_been_checked=0\"'", like => '/^\[\]$/smx', waitfor => '\[\]', maxwait => 10 },

  { cmd => "/bin/su - $site -c 'echo \"GET services\nFilter: host_name = localhost\nFilter: description = check_locale.py\nColumns: state plugin_output long_plugin_output\n\n\" | lq'", like => '/^0;LANG=/' },

  { cmd => "/bin/su - $site -c 'file bin/naemon.dbg'", like => '/not stripped/' },
  { cmd => "/bin/su - $site -c 'file lib/naemon/livestatus.o.dbg'", like => '/not stripped/' },
  { cmd => "/bin/su - $site -c 'file lib/mod_gearman/mod_gearman_naemon.o.dbg'", like => '/not stripped/' },

  # default config should not contain warnings
  { cmd => "/bin/su - $site -c 'omd check core 2>&1'", unlike => ['/Warning:/', '/Error:/'], like => ['/Total Errors:   0/', '/Total Warnings: 0/'] },

  { cmd => $omd_bin." stop $site naemon", unlike => '/kill/i' },

  # test vim vault
  { cmd => "/bin/su - $site -c 'echo \"broker_module=/omd/sites/$site/lib/naemon/vimvault.o vault=etc/naemon/vault.cfg password=test\" > etc/naemon/naemon.d/vimvault.cfg'", like => '/^$/' },
  { cmd => "/bin/cp t/data/naemon/testvault.cfg /omd/sites/$site/etc/naemon/vault.cfg", like => '/^$/' },
  { cmd => "/bin/chown $site: /omd/sites/$site/etc/naemon/vault.cfg", like => '/^$/' },
  { cmd => $omd_bin." start $site naemon", like => '/Starting/' },
  { cmd => $omd_bin." status $site naemon", like => '/naemon:\s*running/' },
  { cmd => "/bin/su - $site -c 'grep \"vault module loaded\" var/log/naemon.log'", like => '/vault module loaded/' },

  { cmd => $omd_bin." stop $site" },

  # test tcp/xinetd
  { cmd => $omd_bin." config $site set LIVESTATUS_TCP on" },
  { cmd => $omd_bin." config $site set LIVESTATUS_TCP_PORT 9999" },
  { cmd => $omd_bin." start $site", like => '/Starting xinetd\.+\s*OK/' },
  { cmd => $omd_bin." status $site", like => '/xinetd:\s+running/' },
  { cmd => "/bin/su - $site -c './lib/monitoring-plugins/check_tcp -H 127.0.0.1 -p 9999 -E -s \"GET status\n\n\" -e \";program_version;\"'", like => '/TCP OK/' },
];
for my $test (@{$tests}) {
    my $rc = TestUtils::test_command($test);
    TestUtils::bail_out_clean("no further testing without site") if(!$rc && $test->{'fatal'});
}

do './t/lib/plugin_outputs.pl';
my $expected_plugin_outputs = get_expected_plugin_outputs(); # test data is shared with the mod-gearman test
for my $hst (sort keys %{$expected_plugin_outputs}) {
  for my $svc (sort keys %{$expected_plugin_outputs->{$hst}}) {
    TestUtils::test_plugin_output({ site => $site, host => $hst, service => $svc, %{$expected_plugin_outputs->{$hst}->{$svc}} });
  }
}

##################################################
# cleanup test site
TestUtils::test_command({ cmd => $omd_bin." stop $site" });
TestUtils::remove_test_site($site);
