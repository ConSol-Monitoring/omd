TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_rittal_health -V'", exit => 0, like => '/^check_rittal_health.*labs.*check_rittal_health/' });
