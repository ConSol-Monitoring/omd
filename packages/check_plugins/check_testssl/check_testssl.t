TestUtils::test_command({
    cmd => "/bin/su - $site -c './lib/nagios/plugins/check_testssl.sh -f https://labs.consol.de'",
    like => '/(TESTSSL OK - All tests passed|is way too old|Network is unreachable|Connection timed out)/',
    exit => undef,
});
