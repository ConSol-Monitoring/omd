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

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

TestUtils::install_test_checks($site);
clean_dumps();

##################################################
# setup debug naemon
my $tests = [
  { cmd => "/bin/su - $site -c 'echo \"export NAEMON_CORE_DEBUG=1\" > etc/profile.d/naemon_debug.sh'" },
  { cmd => $omd_bin." config $site set CORE naemon" },
  { cmd => "/bin/su - $site -c 'cp share/doc/naemon/example.cfg etc/naemon/conf.d/'", like => '/^$/' },
  { cmd => $omd_bin." start $site" },
  { cmd => "/bin/su - $site -c './share/thruk/support/reschedule_all_checks.sh'", like => '/COMMAND/' },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}

##################################################
# test core file usability
##################################################
my $core_pattern = `cat /proc/sys/kernel/core_pattern`;
if($core_pattern =~ m%\Q|/bin/false\E%mx) {
    TestUtils::test_command({ cmd => '/bin/sh -c "echo \"core.%e.%p\" > /proc/sys/kernel/core_pattern"', like => '/^$/' });
    $core_pattern = `cat /proc/sys/kernel/core_pattern`;
}

my $naemonpid = `cat /omd/sites/$site/tmp/run/naemon.pid`; chomp($naemonpid);
TestUtils::test_command({ cmd => "/bin/su - $site -c 'kill -s SIGSEGV $naemonpid'" });

my $corefile;
if($core_pattern =~ m/\|.*systemd\-coredump/mx) {
  TestUtils::test_command({ cmd => "/usr/bin/coredumpctl list | grep -v missing", like => '/naemon/', waitfor => 'naemon' });
  `/usr/bin/coredumpctl dump naemon.dbg > /tmp/core.naemon 2>/dev/null`;
  $corefile = glob("/tmp/core.naemon");
}
elsif($core_pattern =~ m/\|.*apport/mx) {
  TestUtils::test_command({ cmd => "/bin/su - $site -c 'ls /var/crash/*naemon*.crash'", like => '/naemon/', waitfor => 'naemon' });
  $corefile = glob("/var/lib/apport/coredump/*naemon* ");
}
elsif($core_pattern =~ m/\|/mx) {
    fail("unsupported core pattern: ".$core_pattern);
}
else {
  TestUtils::test_command({ cmd => "/bin/su - $site -c 'ls core*'", like => '/core/', waitfor => 'core' });
  $corefile = glob("/omd/sites/".$site."/core* ");
}

ok($corefile, "got corefile: ".($corefile // "none")) or BAIL_OUT("cannot test without core file");
TestUtils::test_command({ cmd => "/bin/su - $site -c 'gdb /omd/sites/".$site."/bin/naemon.dbg -c $corefile -ex \"set pagination off\" -ex bt -ex quit'", like => ['/event_execution_loop/', '/naemon.c:/' ], errlike => undef });
TestUtils::test_command({ cmd => "/bin/rm -f $corefile" });

##################################################
# cleanup test site
TestUtils::remove_test_site($site);
clean_dumps();
done_testing();

##################################################
sub clean_dumps {
  `rm -rf /var/lib/systemd/coredump/* /tmp/core.naemon /var/crash/* /var/lib/apport/coredump/*`;
}