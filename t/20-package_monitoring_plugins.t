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

plan( tests => 44 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

##################################################
# execute some checks
my $tests = [
  { cmd => "/bin/su - $site -c 'test -x lib/nagios/plugins/check_icmp'", exit => 0, like => '/^$/' },
  { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_icmp'",     exit => 3, like => '/check_icmp: No hosts to check/' },
  { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_fping'",    exit => 3, like => '/check_fping: Could not parse arguments/' },
  { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_snmp'",     exit => 3, like => '/check_snmp: Could not parse arguments/' },
  { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_mysql'",exit => undef, like => '/Can\'t connect to local MySQL server through socket|Access denied for user|Open_tables/' },
  { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_logfiles'", exit => 3, like => '/Usage: check_logfiles/' },
  { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -S -H 127.0.0.1 -p 9999'", exit => 2, like => '/HTTP CRITICAL - Unable to open TCP socket/' },
  { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_curl -S -H 127.0.0.1 -p 9999'", exit => 2, like => '/HTTP CRITICAL - Invalid HTTP response received/' },
  { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_by_ssh -V'", exit => 3, like => '/labs/' }, # plugins should contain omd in the version information
  { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_radius -h'", exit => 3, like => '/^check_radius.*/'}, 
];
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}

##################################################
# cleanup test site
TestUtils::remove_test_site($site);
