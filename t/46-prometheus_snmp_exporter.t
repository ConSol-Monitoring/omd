#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
    use FindBin;
    use lib "$FindBin::Bin/lib/lib/perl5";
}

# query the snmp agent t/data/python-modules/snmpsim.py with the site's snmp_exporter,
# credentials are passed as url parameters (patches/0001)
plan( skip_all => "curl is not installed" ) if ! -x "/usr/bin/curl";

my $simport = 16162;
my $export  = 19116;

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");
my $simdir  = "/omd/sites/$site/var/snmpsim";
my $explog  = "$simdir/snmp_exporter.log";
my $exppid  = "$simdir/snmp_exporter.pid";

TestUtils::test_command({ cmd => "/bin/mkdir -p $simdir" });
TestUtils::test_command({ cmd => "/bin/cp t/data/python-modules/snmpsim.py $simdir/" });
TestUtils::test_command({ cmd => "/bin/chown -R $site: $simdir" });

##################################################
# the agent answers v3 and v2c with community omd-v2c, but not "public",
# the default community of the if_mib module
TestUtils::test_command({ cmd => "/bin/su - $site -c 'python3 $simdir/snmpsim.py $simport omd-v2c > $simdir/snmpsim.log 2>&1 < /dev/null & echo \$! > $simdir/snmpsim.pid'" });
TestUtils::test_command({ cmd => "/bin/cat $simdir/snmpsim.log", waitfor => 'listening\ on', maxwait => 30 });

TestUtils::test_command({
    cmd     => "/bin/su - $site -c 'snmp_exporter --version'",
    errlike => '/version 0\.21\.0\+omd \(branch: HEAD, revision: release-tar-ball\)/',
});

sub start_exporter {
    TestUtils::test_command({ cmd => "/bin/su - $site -c 'snmp_exporter --config.file=etc/prometheus_snmp_exporter/config/snmp.yml --web.listen-address=127.0.0.1:$export --log.level=debug >> $explog 2>&1 < /dev/null & echo \$! > $exppid'" });
    TestUtils::test_command({ cmd => "/usr/bin/curl -s --noproxy \\* -o /dev/null -w '%{http_code}' http://127.0.0.1:$export/", waitfor => '200', maxwait => 30 });
}

sub stop_exporter {
    TestUtils::test_command({ cmd => "/bin/su - $site -c 'kill \$(cat $exppid)'" });
    TestUtils::test_command({ cmd => "/usr/bin/curl -s --noproxy \\* -o /dev/null -w '%{http_code}' http://127.0.0.1:$export/", waitfor => '!200', maxwait => 30, exit => undef });
}

# scrape the agent, a working scrape returns the agent's sysUpTime
sub scrape {
    my($params, $ok) = @_;
    TestUtils::test_command({
        cmd  => "/usr/bin/curl -s --noproxy \\* -w '\\nHTTP %{http_code}\\n' 'http://127.0.0.1:$export/snmp?target=127.0.0.1:$simport&module=if_mib$params'",
        like => $ok ? ['/^HTTP 200$/m', '/^sysUpTime \d+/m'] : ['/^HTTP 500$/m', '/snmp_error/'],
    });
}

sub v3 {
    my($user, $auth, $priv) = @_;
    return "&version=3&security_level=authPriv&username=$user&password=auth-$user&auth_protocol=$auth&priv_protocol=$priv&priv_password=priv-$user";
}

##################################################
# AES192/AES256 (Blumenthal) users with different priv passwords,
# gosnmp < 1.36 uses the first derived key for all of them (patches/0002)
for my $bits (qw/256 192/) {
    for my $order ([qw/a b c/], [qw/c b a/]) {
        start_exporter();
        scrape(v3("aes$bits-$_", 'SHA', "AES$bits"), 1) for @{$order};
        stop_exporter();
    }
}

##################################################
# all auth and priv protocols, in exporter spelling
start_exporter();
my @users = (
    [ 'md5-aes',          'MD5',    'AES'     ],
    [ 'sha-aes',          'SHA',    'AES'     ],
    [ 'sha-224-aes',      'SHA224', 'AES'     ],
    [ 'sha-256-aes-192',  'SHA256', 'AES192'  ],
    [ 'sha-384-aes-256',  'SHA384', 'AES256'  ],
    [ 'sha-512-aes-256',  'SHA512', 'AES256'  ],
    [ 'sha-256-aes-192c', 'SHA256', 'AES192C' ],
    [ 'sha-512-aes-256c', 'SHA512', 'AES256C' ],
    [ 'sha-512-aes-256',  'sha512', 'aes256'  ], # patches/0001 upper-cases the protocols
);
scrape(v3(@{$_}), 1) for @users;

# wrong priv password
scrape("&version=3&security_level=authPriv&username=sha-aes&password=auth-sha-aes&auth_protocol=SHA&priv_protocol=AES&priv_password=wrongpassword", 0);

# v2c
scrape("&version=2&community=omd-v2c", 1);

##################################################
# a request without credentials must not inherit those of the previous request,
# it uses the module's community "public" and times out (patches/0003)
scrape(v3('sha-aes', 'SHA', 'AES'), 1);
scrape("", 0);
stop_exporter();

##################################################
# no credentials in the debug log (patches/0004)
TestUtils::test_command({ cmd => "/bin/grep -c -E 'auth-|priv-|omd-v2c' $explog", exit => 1, like => '/^0$/' });
TestUtils::test_command({ cmd => "/bin/grep -c 'Overriding priv_password' $explog", like => '/^[1-9]\d*$/' });
TestUtils::test_command({ cmd => "/bin/grep -c 'Overriding community' $explog", like => '/^[1-9]\d*$/' });

##################################################
# cleanup
TestUtils::test_command({ cmd => "/bin/su - $site -c 'kill \$(cat $simdir/snmpsim.pid)'" });
TestUtils::test_command({ cmd => $omd_bin." stop $site", exit => undef, errlike => undef });
TestUtils::remove_test_site($site);

done_testing();
