TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_printer_health -V'", exit => 0, like => '/Revision.*labs.*check_printer_health/' });
