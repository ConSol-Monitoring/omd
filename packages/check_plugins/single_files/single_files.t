chomp(my $os = qx(./distro));
if($os !~ /(centos 6)|(sles 11)/i) {
  TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_smb_copy -h'", exit => 0, like => '/show this help message and exit/' });
} else {
  diag($os." needs a newer libsmbclient than the one that comes with the distro");
}

TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_livestatus_stats.pl -h'", exit => 3, like => '/Usage: check_livestatus_stats.pl/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_livestatus_stats.pl'",    exit => 0, like => '/LIVESTATS OK - host_checks_rate:/' });
