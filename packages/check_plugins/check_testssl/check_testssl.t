TestUtils::test_command({ cmd => "/bin/su - $site -c './lib/nagios/plugins/check_testssl.sh -f https://labs.consol.de'", exit => 0, like => '/TESTSSL OK - All tests passed/' });
