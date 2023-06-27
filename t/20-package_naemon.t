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

plan( tests => 114 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

`install -m 755 t/lib/check_locale.py /omd/sites/$site/local/lib/monitoring-plugins/`;
`install -m 644 t/data/naemon.cfg /omd/sites/$site/etc/naemon/conf.d/example-naemon.cfg`;

##################################################
# execute some checks
my $tests = [
  { cmd => $omd_bin." config $site set CORE naemon" },

  { cmd => "/bin/su - $site -c 'cp share/doc/naemon/example.cfg etc/naemon/conf.d/'", like => '/^$/' },
  { cmd => $omd_bin." start $site" },

  { cmd => "/bin/su - $site -c 'test -S tmp/run/live'", like => '/^$/' },
  { cmd => "/bin/su - $site -c 'test -p tmp/run/naemon.cmd'", like => '/^$/' },
  { cmd => "/bin/su - $site -c 'test -f var/naemon/livestatus.log'", like => '/^$/' },

  { cmd => "/bin/su - $site -c 'echo \"COMMAND [".time()."] SCHEDULE_FORCED_SVC_CHECK;localhost;locale;".time()."\" | lq'", like => '/^\s*$/' },
  { cmd => "/bin/su - $site -c 'sleep 2'", like => '/^\s*$/' },
  { cmd => "/bin/su - $site -c 'echo \"GET services\nFilter: host_name = localhost\nFilter: description = locale\nColumns: state plugin_output long_plugin_output\n\n\" | lq'", like => '/^0;LANG=/' },

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

  { cmd => $omd_bin." stop $site" },

];
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}

##################################################
# cleanup test site
TestUtils::remove_test_site($site);
