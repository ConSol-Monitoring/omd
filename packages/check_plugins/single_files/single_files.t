chomp(my $os = qx(./distro));
if($os !~ /(sles 1[12])/i) {
  TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_smb_copy -h'", exit => 0, like => '/show this help message and exit/' });
} else {
  diag($os." check_smb_copy cannot be built with SLES12' python3.4");
}

TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_livestatus_stats.pl -h'", exit => 3, like => '/Usage: check_livestatus_stats.pl/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_livestatus_stats.pl'",    exit => 0, like => '/LIVESTATS OK - host_checks_rate:/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_meminfo'",    exit => 0, like => '/--help, -h/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_meminfo -m MEMUSED -w 1 --op gt'",    exit => 1, like => '/^WARNING/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_meminfo -m MEMUSED -c 1 --op gt'",    exit => 2, like => '/^CRITICAL/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_meminfo -m MEMUSED -c 1 --op lt'",    exit => 0, like => '/^OK/' });
