TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_mssql_health -V'", exit => 0, like => '/^check_mssql_health/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_mssql_health --hostname localhost --username test --password test --mode connection-time --timeout 1'", exit => 2, like => '/CRITICAL - connection could not be established within 1 seconds/' });

