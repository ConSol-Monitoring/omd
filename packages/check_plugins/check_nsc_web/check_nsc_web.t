# print version
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_nsc_web -V'", exit => 3, like => '/^check_nsc_web/' });
# make sure -r options exists
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_nsc_web -r -p test -u http://localhost:1234'", exit => 3, like => '/dial tcp/' });
