TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_smb_copy -h'", exit => 0, like => '/show this help message and exit/' });
