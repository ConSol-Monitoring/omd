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

plan( tests => 55 );

##################################################
# create our test site
my $omd_bin   = TestUtils::get_omd_bin();
my $site      = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");
my $startTime = time-9;


#my $site = 'testsite';

# remove victoriametrics auth via empty config file:
TestUtils::test_command({ cmd => "/bin/su - $site -c \"echo '# dummy config' > ~$site/etc/victoriametrics/victoriametrics.conf\" ", errlike => '/^$/'});

# for test
TestUtils::test_command({ cmd => $omd_bin." stop $site " , like => '/Stopp.*OK/' });
 #, waitfor => '/.*victoria.*/' });
# end for test

TestUtils::test_command({ cmd => $omd_bin." config $site set VICTORIAMETRICS on" });
TestUtils::test_command({ cmd => $omd_bin." config $site set PNP4NAGIOS off" });
TestUtils::test_command({ cmd => $omd_bin." config $site set NAGFLUX on" });
TestUtils::test_command({ cmd => $omd_bin." config $site set CORE naemon" });
# switch target to victoriametrics
TestUtils::test_command({ cmd => "/usr/bin/env sed -e '/^\\[InfluxDB .nagflux.\\]/,/^\\[/{s%^\\(\\s*Enabled\\).*%\\1 = false %}' -i ~$site/etc/nagflux/config.gcfg"});
TestUtils::test_command({ cmd => "/usr/bin/env sed -e '/^\\[InfluxDB .victoriametrics.\\]/,/^\\[/{s%^\\(\\s*Enabled\\).*%\\1 = true %}' -i ~$site/etc/nagflux/config.gcfg"});

# enable nagflux logging:
TestUtils::test_command({ cmd => "/usr/bin/env sed -e 's/\\(\\s*MinSeverity\\).*/\\1 = \"DEBUG\"/' -i ~$site/etc/nagflux/config.gcfg"});


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


#Test if database is up
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -t 60 -H 127.0.0.1 -p 8428 -u \"/health\"  '", like => '/HTTP OK:/', waitfor => 'HTTP\ OK:' });

#Mock Nagios and write spoolfiles
TestUtils::test_command({ cmd => "/bin/su - $site -c 'cat > var/pnp4nagios/spool/ranges $ranges'"});

# wait untill all data is inserted: 20 
TestUtils::test_url({
    url            => "http://127.0.0.1:8428/api/v1/query?query=count(max_over_time(\{host=~\"xx.*\"\}[10m]))",
    like           => [ "/.*metrics.*/" ],
    waitfor        => ".*value\":\\\[.*,\"20.*",
});


#Search for inserted data
# check only sum of all entries, as the order may change
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -t 60 -H 127.0.0.1 -p 8428 -u \"/api/v1/query?query=sum(max_over_time(\{__name__=~\\\"metrics.*\\\",host=\\\"xxx\\\",service=\\\"range\\\",performanceLabel=\\\"a%20used\\\"\}\[10m\]))\"  -r\"\\\"value\\\":\\\[.*,\\\"91\\\"\\\]\" -v '", like => '/HTTP OK:/' });

#Clean up
TestUtils::remove_test_site($site);
