#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use Sys::Hostname;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
    use FindBin;
    use lib "$FindBin::Bin/lib/lib/perl5";
}

plan( tests => 39 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");
my $curl    = '/usr/bin/curl --user root:root';

TestUtils::test_command({ cmd => $omd_bin." config $site set INFLUXDB on" });
TestUtils::test_command({ cmd => $omd_bin." start $site", like => '/Starting influxdb...OK/' });
sleep(2); # influxdb api returns 404 when accessed directly after first start
TestUtils::test_command({ cmd => $curl.' -kv -G "http://localhost:8086/ping"', like => '/^$/', errlike => ['/X-Influxdb-Version:/']});
#Create database
TestUtils::test_command({ cmd => $curl.' -s -G "http://localhost:8086/query" --data-urlencode "q=CREATE DATABASE mydb"', like => '/\{"results":\[\{\}\]/', errlike => '/.*/'});
#Insert dummy data
TestUtils::test_command({ cmd => $curl.' -s -XPOST "http://localhost:8086/write" -d \'{ "database": "mydb", "retentionPolicy": "default", "points": [{ "name": "cpu_load_short", "tags": { "host": "server01", "region": "us-west" }, "time": "2009-11-10T23:00:00Z", "fields": { "value": 0.64 }} ]}\''});
#Test dummy data
TestUtils::test_command({ cmd => $curl.' -s -G "http://localhost:8086/query" --data-urlencode "db=mydb" --data-urlencode "q=SELECT value FROM cpu_load_short WHERE region=\'us-west\'"', like => '/.*"name":"cpu_load_short".*/'});
#Drop database
TestUtils::test_command({ cmd => $curl.' -s -G "http://localhost:8086/query" --data-urlencode "q=DROP DATABASE mydb"', like => '/\{"results":\[\{\}\]/'});
#Test if database is realy droped
TestUtils::test_command({ cmd => $curl.' -s -G "http://localhost:8086/query" --data-urlencode "db=mydb" --data-urlencode "q=SELECT value FROM cpu_load_short WHERE region=\'us-west\'"', like => '/.*database not found: mydb.*/'});
TestUtils::test_command({ cmd => $omd_bin." stop $site" });
TestUtils::remove_test_site($site);

