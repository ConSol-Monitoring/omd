TestUtils::test_command({ cmd => "/bin/cp -rp packages/check_plugins/check_nwc_health/test.snmpwalk /tmp"});
TestUtils::test_command({ cmd => "/bin/cp -rp packages/check_plugins/check_nwc_health/CheckNwcHealthTest.pm /tmp"});
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_nwc_health -V'", exit => 0, like => '/Revision.*labs.*check_nwc_health/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_nwc_health --snmpwalk /tmp/test.snmpwalk --mode my-nwc-test --with-mymodules-dyn-dir=/tmp'", exit => 1, like => '/WARNING - delta_counter is 11/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_nwc_health --snmpwalk /tmp/test.snmpwalk --mode my-nwc-test --with-mymodules-dyn-dir=/tmp'", exit => 2, like => '/CRITICAL - delta_counter is 0/' });
TestUtils::test_command({ cmd => "/bin/rm -f /tmp/test.snmpwalk"});
TestUtils::test_command({ cmd => "/bin/rm -f /tmp/CheckNwcHealthTest.pm"});
