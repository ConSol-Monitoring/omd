TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_mysql_health -V'", exit => 0, like => '/^check_mysql_health/' });
