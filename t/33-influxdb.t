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
TestUtils::test_command({ cmd => $omd_bin." start $site", like => '/Starting influxdb\.+OK/' });
sleep(2); # influxdb api returns 404 when accessed directly after first start

#http api
#create database
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 60 -H localhost -p 8086 -u \"/query\" -P \"q=CREATE%20DATABASE%20mydb\" -a \"omdadmin:omd\" -s \"{\\\"results\\\":[{}]}\"'", like => '/HTTP OK:/' });
#write data
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 60 -H localhost -p 8086 -u \"/write?db=mydb\" -a \"omdadmin:omd\" -P \"cpu_load_short,host=server01,region=us-west value=0.64 1434055562000000000\"'", like => '/HTTP OK:/' });
#read data
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 60 -H localhost -p 8086 -u \"/query?db=mydb&q=SELECT%20*%20FROM%20cpu_load_short\" -a \"omdadmin:omd\" -s \"{\\\"results\\\":[{\\\"series\\\":[{\\\"name\\\":\\\"cpu_load_short\\\",\\\"columns\\\":[\\\"time\\\",\\\"host\\\",\\\"region\\\",\\\"value\\\"],\\\"values\\\":[[\\\"2015-06-11T20:46:02Z\\\",\\\"server01\\\",\\\"us-west\\\",0.64]]}]}]}\"'", like => '/HTTP OK:/' });
#drop database
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 60 -H localhost -p 8086 -u \"/query\" -P \"q=DROP%20DATABASE%20mydb\" -a \"omdadmin:omd\" -s \"{\\\"results\\\":[{}]}\"'", like => '/HTTP OK:/' });
#is it gone?
#TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 60 -H localhost -p 8086 -u \"/query\" -P \"q=SHOW%20DATABASES\" -a \"omdadmin:omd\" -s \"{\\\"results\\\":[{\\\"series\\\":[{\\\"name\\\":\\\"databases\\\",\\\"columns\\\":[\\\"name\\\"],\\\"values\\\":[[\\\"nagflux\\\"],[\\\"_internal\\\"]]}]}]}\"'", like => '/HTTP OK:/' }); #skip this now for now
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 60 -H localhost -p 8086 -u \"/query\" -P \"q=SHOW%20DATABASES\" -a \"omdadmin:omd\"'", like => '/HTTP OK:/' });

TestUtils::test_command({ cmd => $omd_bin." stop $site" });
TestUtils::remove_test_site($site);

