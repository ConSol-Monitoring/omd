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

# start an snmp agent written with the site's pysnmp (t/data/python-modules/snmpsim.py)
# and query it with net-snmp's snmpwalk (v2c and v3 authPriv)
my $snmpwalk = -x "/bin/snmpwalk" ? "/bin/snmpwalk" : -x "/usr/bin/snmpwalk" ? "/usr/bin/snmpwalk" : undef;
plan( skip_all => "snmpwalk is not installed" ) if ! defined $snmpwalk;

# auth/priv protocols supported by the local net-snmp (CentOS 7: MD5|SHA and DES|AES only)
my $help = qx($snmpwalk -h 2>&1);
my %supported;
for my $opt (qw/a x/) {
    if($help =~ m/^\s+-$opt\s+PROTOCOL\s+.*?\(([^)]+)\)/mx) {
        $supported{$opt}->{$_} = 1 for split(/\|/mx, $1);
    }
}

# user names and passwords as defined in snmpsim.py
my @users = (
    [ 'MD5',     'AES'     ],
    [ 'SHA',     'AES'     ],
    [ 'SHA-224', 'AES'     ],
    [ 'SHA-256', 'AES-192' ],
    [ 'SHA-384', 'AES-256' ],
    [ 'SHA-512', 'AES-256' ],
);
my $port = 16161;
# net-snmp may create its persistent directories on the first run
my $snmperr = '/^(Created directory: \S+\s*)*$/';

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");
my $simdir  = "/omd/sites/$site/var/snmpsim";

TestUtils::test_command({ cmd => "/bin/mkdir -p $simdir" });
TestUtils::test_command({ cmd => "/bin/cp t/data/python-modules/snmpsim.py $simdir/" });
TestUtils::test_command({ cmd => "/bin/chown -R $site: $simdir" });

##################################################
# the simulator must run with the pysnmp/crypto combination selected for the site's python
my $pyver = { cmd => "/bin/su - $site -c 'python3 -c \"import sys; print(sys.version_info >= (3, 12))\"'", like => '/^(True|False)$/' };
TestUtils::test_command($pyver);
my $py312 = $pyver->{'stdout'} =~ m/True/mx;

TestUtils::test_command({ cmd => "/bin/su - $site -c 'python3 $simdir/snmpsim.py $port public > $simdir/snmpsim.log 2>&1 < /dev/null & echo \$! > $simdir/snmpsim.pid'" });
TestUtils::test_command({ cmd => "/bin/cat $simdir/snmpsim.log", waitfor => 'listening\ on', maxwait => 30 });
if($py312) {
    # pysnmp 7 encrypts with the OS python3-cryptography, never with an OMD-bundled copy
    TestUtils::test_command({ cmd => "/bin/cat $simdir/snmpsim.log",
        like   => ['/^pysnmp 7\.\d+\.\d+ \(asyncio\)/m', '/^crypto cryptography \S+ \//m'],
        unlike => ['/^crypto \S+ \S+ \/omd\//m', '/^crypto \S+ \S+ \/opt\/omd\//m'],
    });
} else {
    # pysnmp 4.4 encrypts with pycryptodomex from the site's lib/python
    TestUtils::test_command({ cmd => "/bin/cat $simdir/snmpsim.log",
        like   => ['/^pysnmp 4\.4\.\d+ \(asyncore\)/m', '/^crypto pycryptodomex \S+ \S*\/omd\/\S+\/Cryptodome\//m'],
    });
}
my $sim = { cmd => "/bin/cat $simdir/snmpsim.log", like => '/^pysnmp (\d+\.\d+\.\d+)/m' };
TestUtils::test_command($sim);
my($pysnmp_version) = $sim->{'stdout'} =~ m/^pysnmp\s+(\S+)/mx;
$pysnmp_version = quotemeta($pysnmp_version // 'unknown');

##################################################
# SNMP v2c
TestUtils::test_command({
    cmd  => "$snmpwalk -On -t 5 -r 1 -v2c -c public 127.0.0.1:$port 1.3.6.1.2.1.1",
    like    => ['/^\.1\.3\.6\.1\.2\.1\.1\.1\.0 = STRING: "?PySNMP engine version '.$pysnmp_version.'/m',
                '/^\.1\.3\.6\.1\.2\.1\.1\.2\.0 = OID:/m'],
    errlike => $snmperr,
});
TestUtils::test_command({
    cmd     => "$snmpwalk -On -t 1 -r 0 -v2c -c wrongcommunity 127.0.0.1:$port 1.3.6.1.2.1.1",
    exit    => 1,
    errlike => '/Timeout/',
});

##################################################
# SNMP v3 authPriv
for my $u (@users) {
    my($auth, $priv) = @{$u};
    my $user = lc($auth.'-'.$priv);
    SKIP: {
        skip("net-snmp does not support $auth/$priv", 5)
            unless $supported{'a'}->{$auth} && $supported{'x'}->{$priv};
        TestUtils::test_command({
            cmd  => "$snmpwalk -On -t 5 -r 1 -v3 -l authPriv -u $user -a $auth -A auth-$user -x $priv -X priv-$user 127.0.0.1:$port 1.3.6.1.2.1.1",
            like => ['/^\.1\.3\.6\.1\.2\.1\.1\.1\.0 = STRING: "?PySNMP engine version '.$pysnmp_version.'/m',
                     '/^\.1\.3\.6\.1\.2\.1\.1\.2\.0 = OID:/m'],
            errlike => $snmperr,
        });
    };
}

# wrong passwords must be rejected (pysnmp 7 sends a report, pysnmp 4.4 drops the request)
TestUtils::test_command({
    cmd     => "$snmpwalk -On -t 2 -r 0 -v3 -l authPriv -u sha-aes -a SHA -A auth-sha-aes -x AES -X wrongpassword 127.0.0.1:$port 1.3.6.1.2.1.1",
    exit    => 1,
    unlike  => '/PySNMP/',
    errlike => $py312 ? '/Decryption error/' : '/(Decryption error|Timeout)/',
});
TestUtils::test_command({
    cmd     => "$snmpwalk -On -t 2 -r 0 -v3 -l authPriv -u sha-aes -a SHA -A wrongpassword -x AES -X priv-sha-aes 127.0.0.1:$port 1.3.6.1.2.1.1",
    exit    => 1,
    unlike  => '/PySNMP/',
    errlike => $py312 ? '/Authentication failure/' : '/(Authentication failure|Timeout)/',
});

##################################################
# cleanup
TestUtils::test_command({ cmd => "/bin/su - $site -c 'kill \$(cat $simdir/snmpsim.pid)'" });
TestUtils::test_command({ cmd => $omd_bin." stop $site", exit => undef, errlike => undef });
TestUtils::remove_test_site($site);

done_testing();
