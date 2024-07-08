chomp(my $os = qx(./distro));
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_mssql_health -V'", exit => 0, like => '/^check_mssql_health/' });
plan( skip_all => qq{ansible doesn't work on $os}) if $os =~ /SLES 11SP[12]/;
SKIP: {
  skip 'test not supported on suse', 1 if $os =~ /(OPENSUSE)|(UBUNTU 22.04)/;
  TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_mssql_health --hostname localhost --username test --password test --mode connection-time --timeout 1'", exit => 2, like => '/CRITICAL - connection could not be established within 1 seconds/' });
}

