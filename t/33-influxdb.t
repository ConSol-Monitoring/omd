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

plan( tests => 72 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");
my $curl    = '/usr/bin/curl -v --user omdadmin:omd --noproxy \* ';
my $ip      = TestUtils::get_external_ip();

TestUtils::test_command({ cmd => $omd_bin." config $site set INFLUXDB on" });
TestUtils::test_command({ cmd => $omd_bin." start $site", like => '/Starting influxdb.+OK/' });
sleep(5); # influxdb api returns 404 when accessed directly after first start

#http api
#create database
TestUtils::test_command({ cmd     => "/bin/su - $site -c '$curl http://127.0.0.1:8086/query --data \"q=CREATE%20DATABASE%20mydb\"'",
                          errlike => ['/HTTP\/1\.1 200 OK/'], 
                          like    => ['/\{"results":\[\{"statement_id":0\}\]\}/'],
                       });
#write data
TestUtils::test_command({ cmd     => "/bin/su - $site -c '$curl \"http://127.0.0.1:8086/write?db=mydb\" --data \"cpu_load_short,host=server01,region=us-west value=0.64 1434055562000000000\"'",
                          errlike => ['/HTTP\/1\.1 204 No Content/'],
                          like    => [ '/^$/' ],
                       });
#read data
TestUtils::test_command({ cmd     => "/bin/su - $site -c '$curl \"http://127.0.0.1:8086/query?db=mydb&q=SELECT%20*%20FROM%20cpu_load_short\"'",
                          errlike => ['/HTTP\/1\.1 200 OK/'], 
                          like    => [ '/\{"results":\[\{"statement_id":0,"series":\[\{"name":"cpu_load_short","columns":\["time","host","region","value"\],"values":\[\["2015-06-11T20:46:02Z","server01","us-west",0.64\]\]\}\]\}\]\}/' ],
                       });
#drop database
TestUtils::test_command({ cmd     => "/bin/su - $site -c '$curl \"http://127.0.0.1:8086/query\" --data \"q=DROP%20DATABASE%20mydb\"'",
                          errlike => ['/HTTP\/1\.1 200 OK/'], 
                          like    => ['/\{"results":\[\{"statement_id":0\}\]\}/'],
                       });
TestUtils::test_command({ cmd => "/bin/su - $site -c '$curl \"http://127.0.0.1:8086/query\" --data \"q=SHOW%20DATABASES\"'",
                          errlike => ['/HTTP\/1\.1 200 OK/'], 
                          like    => ['/\{"results":\[\{"statement_id":0,"series":\[\{"name":"databases","columns":\["name"\],"values":/'],
                       });

# make sure influxdb listens to localhost only
TestUtils::test_command({ cmd => "/bin/su - $site -c '$curl \"http://$ip:8086/query\" --data \"q=SHOW%20DATABASES\"'",
                          errlike => ['/(Failed to connect|Connection refused)/'], 
                          unlike  => ['/HTTP\/1\.1 200 OK/', '/"results":/'],
                          exit    => undef,
                       });

# test cli
TestUtils::test_command({ cmd => "/bin/su - $site -c 'influx'",
                          like    => ['/nagflux/', '/_internal/'],
                          stdin   => ['SHOW DATABASES'],
                       });

TestUtils::test_command({ cmd => "/bin/su - $site -c './lib/monitoring-plugins/check_influxdb m ping --address http://127.0.0.1:8086'",
                          like    => ['/OK/'],
                       });


# enable ssl influxdb
TestUtils::test_command({ cmd => $omd_bin." stop $site" });
TestUtils::test_command({ cmd => $omd_bin." config $site set INFLUXDB_MODE ssl" });
TestUtils::test_command({ cmd => $omd_bin." start $site", like => '/Starting influxdb.+OK/' });

# test cli
TestUtils::test_command({ cmd => "/bin/su - $site -c 'influx'",
                          like    => ['/nagflux/', '/_internal/'],
                          stdin   => ['SHOW DATABASES'],
                       });

TestUtils::test_command({ cmd => "/bin/su - $site -c './lib/monitoring-plugins/check_influxdb m ping --address https://127.0.0.1:8086 --unsafessl'",
                          like    => ['/OK/'],
                       });

TestUtils::test_command({ cmd => $omd_bin." stop $site" });
TestUtils::remove_test_site($site);

