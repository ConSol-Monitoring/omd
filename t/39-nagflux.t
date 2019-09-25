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

plan( tests => 41 );

##################################################
# create our test site
my $omd_bin   = TestUtils::get_omd_bin();
my $site      = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");
my $curl      = '/usr/bin/curl --user root:root';
my $startTime = time-60;

TestUtils::test_command({ cmd => $omd_bin." config $site set INFLUXDB on" });
TestUtils::test_command({ cmd => $omd_bin." config $site set PNP4NAGIOS off" });
TestUtils::test_command({ cmd => $omd_bin." config $site set NAGFLUX on" });
TestUtils::test_command({ cmd => $omd_bin." config $site set CORE naemon" });
TestUtils::test_command({ cmd => $omd_bin." start $site", like => '/Starting Nagflux\.+OK/' });

my $ranges = sprintf("<<END
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::range	SERVICEPERFDATA::a used=4	SERVICECHECKCOMMAND::check_ranges!-w 3: -c 4: -g :46 -l :48	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::range	SERVICEPERFDATA::a used=4;2;10	SERVICECHECKCOMMAND::check_ranges!-w 3: -c 4: -g :46 -l :48	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::range	SERVICEPERFDATA::a used=4;2;10;1;4	SERVICECHECKCOMMAND::check_ranges!-w 3: -c 4: -g :46 -l :48	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::range	SERVICEPERFDATA::a used=4;2:4;8:10;1;4	SERVICECHECKCOMMAND::check_ranges!-w 3: -c 4: -g :46 -l :48	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::range	SERVICEPERFDATA::a used=4;\@2:4;\@8:10;1;4	SERVICECHECKCOMMAND::check_ranges!-w 3: -c 4: -g :46 -l :48	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::range	SERVICEPERFDATA::a used=4;2:;10:;1;4	SERVICECHECKCOMMAND::check_ranges!-w 3: -c 4: -g :46 -l :48	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::range	SERVICEPERFDATA::a used=4;:2;:10;1;4	SERVICECHECKCOMMAND::check_ranges!-w 3: -c 4: -g :46 -l :48	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::range	SERVICEPERFDATA::a used=4;~:2;10:~;1;4	SERVICECHECKCOMMAND::check_ranges!-w 3: -c 4: -g :46 -l :48	SERVICESTATE::0	SERVICESTATETYPE::1

END
",$startTime,$startTime+1,$startTime+2,$startTime+3,$startTime+4,$startTime+5,$startTime+6,$startTime+7);

#Mock Nagios and write spoolfiles
TestUtils::test_command({ cmd => "/bin/su - $site -c 'cat > var/pnp4nagios/spool/ranges $ranges'"});

# wait till data is processed
TestUtils::test_url({
    url            => "http://127.0.0.1:8086/query?db=nagflux&q=SELECT%20COUNT(*)%20FROM%20metrics%20WHERE%20host%3D%27xxx%27%20AND%20service%3D%27range%27%20AND%20performanceLabel%3D%27a%20used%27",
    auth           => "InfluxDB:omdadmin:omd",
    like           => [ "/count_max/" ],
    waitfor        => "5,2,2,6,6,8,5,2,2",
});

#Test if database is up
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -t 60 -H 127.0.0.1 -p 8086 -u \"/query\" -P \"q=SHOW%20DATABASES\" -a \"omdadmin:omd\" -s \"nagflux\" '", like => '/HTTP OK:/' });

#Search for inserted data
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -t 60 -H 127.0.0.1 -p 8086 -u \"/query?db=nagflux&q=SELECT%20COUNT(*)%20FROM%20metrics%20WHERE%20host%3D%27xxx%27%20AND%20service%3D%27range%27%20AND%20performanceLabel%3D%27a%20used%27\" -a \"omdadmin:omd\" -s\"{\\\"results\\\":[{\\\"statement_id\\\":0,\\\"series\\\":[{\\\"name\\\":\\\"metrics\\\",\\\"columns\\\":[\\\"time\\\",\\\"count_crit\\\",\\\"count_crit-max\\\",\\\"count_crit-min\\\",\\\"count_max\\\",\\\"count_min\\\",\\\"count_value\\\",\\\"count_warn\\\",\\\"count_warn-max\\\",\\\"count_warn-min\\\"],\\\"values\\\":[[\\\"1970-01-01T00:00:00Z\\\",5,2,2,6,6,8,5,2,2]]}]}]}\" '", like => '/HTTP OK:/' });

#Clean up
TestUtils::test_command({ cmd => $omd_bin." stop $site" });
TestUtils::remove_test_site($site);

