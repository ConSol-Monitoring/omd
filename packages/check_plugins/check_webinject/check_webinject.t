TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_webinject'", exit => 3, like => '/find any test case files to run./' });
