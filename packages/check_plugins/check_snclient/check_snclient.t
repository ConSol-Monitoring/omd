# renamed check_nsc_web to check_snclient, but kept a symlink
# print version
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_snclient -V'", exit => 3, like => '/^check_snclient/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_nsc_web -V'", exit => 3, like => '/^check_snclient/' });
# make sure -r options exists
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_snclient -r -p test -u http://localhost:1234'", exit => 3, like => '/dial tcp/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_nsc_web -r -p test -u http://localhost:1234'", exit => 3, like => '/dial tcp/' });
