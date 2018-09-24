TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_nwc_health -V'", exit => 0, like => '/Revision.*labs.*check_nwc_health/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_nwc_health --snmpwalk test.snmpwalk --mode my-nwc-test --with-mymodules-dyn-dir=`pwd`'", exit => 0, like => '/Revision.*labs.*check_nwc_health/' });
