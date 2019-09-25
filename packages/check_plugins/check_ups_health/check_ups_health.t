TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_ups_health -V'", exit => 0, like => '/Revision.*labs.*check_ups_health/' });
