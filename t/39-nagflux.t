#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use Sys::Hostname;
use Term::ReadLine;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
    use FindBin;
    use lib "$FindBin::Bin/lib/lib/perl5";
}

plan( tests => 94 );

##################################################
# create our test site
my $omd_bin   = TestUtils::get_omd_bin();
my $site      = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");
my $curl      = '/usr/bin/curl --user root:root';
# Pre-filled array of 100 timestamps
my @timestamps = ();
my $base_time = time();
for my $i (0..99) {
    push @timestamps, $base_time - (99 - $i);
}
my $term = Term::ReadLine->new('Test Script');

# Set up OMD, enable services to use

TestUtils::test_command({ cmd => $omd_bin." config $site set INFLUXDB on" });
TestUtils::test_command({ cmd => $omd_bin." config $site set PNP4NAGIOS off" });
TestUtils::test_command({ cmd => $omd_bin." config $site set NAGFLUX on" });
TestUtils::test_command({ cmd => $omd_bin." config $site set CORE naemon" });
TestUtils::test_command({ cmd => $omd_bin." start $site", like => '/Starting nagflux\.+OK/' });

###### TEST 1: Normal parsing

my $ranges = sprintf("<<END
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::range	SERVICEPERFDATA::a used=4	SERVICECHECKCOMMAND::check_ranges!-w 3: -c 4: -g :46 -l :48	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::range	SERVICEPERFDATA::a used=4;2;10	SERVICECHECKCOMMAND::check_ranges!-w 3: -c 4: -g :46 -l :48	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::range	SERVICEPERFDATA::a used=4;2;10;1;4	SERVICECHECKCOMMAND::check_ranges!-w 3: -c 4: -g :46 -l :48	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::range	SERVICEPERFDATA::a used=4;2:4;8:10;1;4	SERVICECHECKCOMMAND::check_ranges!-w 3: -c 4: -g :46 -l :48	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::range	SERVICEPERFDATA::a used=4;\@2:4;\@8:10;1;4	SERVICECHECKCOMMAND::check_ranges!-w 3: -c 4: -g :46 -l :48	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::range	SERVICEPERFDATA::a used=4;2:;10:;1;4	SERVICECHECKCOMMAND::check_ranges!-w 3: -c 4: -g :46 -l :48	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::range	SERVICEPERFDATA::a used=4;:2;:10;1;4	SERVICECHECKCOMMAND::check_ranges!-w 3: -c 4: -g :46 -l :48	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::test1	SERVICEPERFDATA::a used=4;~:2;10:~;1;4	SERVICECHECKCOMMAND::check_ranges!-w 3: -c 4: -g :46 -l :48	SERVICESTATE::0	SERVICESTATETYPE::1

END
",$timestamps[0],$timestamps[1],$timestamps[2],$timestamps[3],$timestamps[4],$timestamps[5],$timestamps[6],$timestamps[7]);

# Mock Nagios and write spoolfiles
TestUtils::test_command({ cmd => "/bin/su - $site -c 'cat > var/pnp4nagios/spool/ranges $ranges'"});

# OMD[testsite@jelinek]:~$ lib/monitoring-plugins/check_http -t 60 -H 127.0.0.1 -p 8086 -u "/query" -P "q=SHOW%20DATABASES" -a "omdadmin:omd" -s "nagflux"

# Test if database is up
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -t 60 -H 127.0.0.1 -p 8086 -u \"/query\" -P \"q=SHOW%20DATABASES\" -a \"omdadmin:omd\" -s \"nagflux\" '", like => '/HTTP OK:/' });

# Check if data is processed
TestUtils::test_url({
    url            => "http://127.0.0.1:8086/query?db=nagflux&q=SELECT%20COUNT(*)%20FROM%20metrics%20WHERE%20host%3D%27xxx%27%20AND%20service%3D%27range%27%20AND%20performanceLabel%3D%27a%20used%27",
    auth           => "InfluxDB:omdadmin:omd",
    like           => [ "/count_max/" ],
    waitfor        => "4,2,2,5,5,7,4,2,2",
    maxwait        => "120",
});

###### TEST 2: Filtering out faulty perfdata lines

# Add perfdata Filter to config

my $configPerdataLengthFilter = "
[NagiosSpoolfile]
    PerfdataLabelMaxLength = 32
    PerfdataUOMMaxLength = 16
    PerfdataNumericValuesMaxLength = 32
    PerfdataThresholdsMaxLength = 64
";

TestUtils::test_command({
    cmd => "/bin/echo '$configPerdataLengthFilter' | /bin/su - $site -c 'cat >> etc/nagflux/config.gcfg'"
});

TestUtils::test_command({ cmd => "/bin/su - $site -c 'omd restart nagflux' "});

# Test if database is up
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -t 60 -H 127.0.0.1 -p 8086 -u \"/query\" -P \"q=SHOW%20DATABASES\" -a \"omdadmin:omd\" -s \"nagflux\" '", like => '/HTTP OK:/' });

# Drop metrics table
TestUtils::test_command({
    cmd => q(/bin/su - ) . $site . q( -c "influx -host 127.0.0.1 -port 8086 -username omdadmin -password omd -database nagflux -execute \"DROP MEASUREMENT metrics\" "),
});

# First and the last ones are valid,
# The ones in the middle are all invalid. they should be rejected
my $perfdataLengthFilterLines = sprintf("<<END
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::range	SERVICEPERFDATA::a used=4	SERVICECHECKCOMMAND::perfdataLengthCheckBegin	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::range	SERVICEPERFDATA::'i_am_a_very_long_performance_label_exceeding_the_default_limit_for_performance_labels_yeah'=35512320B;;;;	SERVICECHECKCOMMAND::perfdataLengthCheckDiscarded	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::range	SERVICEPERFDATA::'label'=123456789123456789123456789123456789;;;;	SERVICECHECKCOMMAND::perfdataLengthCheckDiscarded	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::range	SERVICEPERFDATA::'label'=1iamaverylonguomthatshouldberejected;;;;	SERVICECHECKCOMMAND::perfdataLengthCheckDiscarded	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::range	SERVICEPERFDATA::'label'=1;123456789123456789123456789123456789:123456789123456789123456789123456789;;;	SERVICECHECKCOMMAND::perfdataLengthCheckDiscarded	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::range	SERVICEPERFDATA::'label'=1;;123456789123456789123456789123456789:123456789123456789123456789123456789;;	SERVICECHECKCOMMAND::perfdataLengthCheckDiscarded	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::range	SERVICEPERFDATA::'label'=1;;;123456789123456789123456789123456789;	SERVICECHECKCOMMAND::perfdataLengthCheckDiscarded	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::range	SERVICEPERFDATA::'label'=1;;;;123456789123456789123456789123456789	SERVICECHECKCOMMAND::perfdataLengthCheckDiscarded	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::range	SERVICEPERFDATA::passme=1 failme=1;1:2;3:4;5;6-hello-i-am-garbage-string-that-should-be-detected-as-i-am-not-whitespace	SERVICECHECKCOMMAND::perfdataLengthCheckDiscarded	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::range	SERVICEPERFDATA::passme=1 failme=1;1:2;3:4;5;6-garbage foo bar xyz=3;4afvdv23	SERVICECHECKCOMMAND::perfdataLengthCheckDiscarded	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::range	SERVICEPERFDATA::xyz=3;45afv	SERVICECHECKCOMMAND::perfdataLengthCheckDiscarded	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::range	SERVICEPERFDATA::label=1;2;label2	SERVICECHECKCOMMAND::perfdataLengthCheckDiscarded	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::range	SERVICEPERFDATA::asd label=1;2; other=1;3;4asdasdasd	SERVICECHECKCOMMAND::perfdataLengthCheckDiscarded	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::range	SERVICEPERFDATA::asd label=1;2; other=1;3;4asdasdasd  [anza=ffgg] [si signo=11] 'valid[1]'=5 [si_errno=0] [si_code=1]	SERVICECHECKCOMMAND::perfdataLengthCheckDiscarded	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::range	SERVICEPERFDATA::asd label=1;2; other=1;3;4asdasdasd  [anza=ffgg] [si signo=11] 'valid[1]'=5 [si_errno=0] [si_code=1]fasdgew	SERVICECHECKCOMMAND::perfdataLengthCheckDiscarded	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::xxx	SERVICEDESC::test2	SERVICEPERFDATA::a used=4	SERVICECHECKCOMMAND::perfdataLengthCheckEnd	SERVICESTATE::0	SERVICESTATETYPE::1
END
",$timestamps[11],$timestamps[12],$timestamps[13],$timestamps[14],$timestamps[15],$timestamps[16],$timestamps[17],$timestamps[18],$timestamps[19],$timestamps[20],$timestamps[21],$timestamps[22],$timestamps[23],$timestamps[24],$timestamps[25],$timestamps[26]);

# Mock Nagios and write spoolfiles
TestUtils::test_command({ cmd => "/bin/su - $site -c 'cat > var/pnp4nagios/spool/ranges $perfdataLengthFilterLines'"});

#Wait for data in influxdb
TestUtils::test_url({
    url            => "http://127.0.0.1:8086/query?db=nagflux&q=SELECT%20*%20FROM%20metrics",
    auth           => "InfluxDB:omdadmin:omd",
    like           => [ "/test2/" ],
    waitfor        => "test2",
    maxwait        => "120",
});

TestUtils::test_command({
    cmd     => q(/bin/su - ) . $site . q( -c "influx -host 127.0.0.1 -port 8086 -username omdadmin -password omd -database nagflux -execute \"SELECT * FROM metrics WHERE command='perfdataLengthCheckBegin'\" | grep perfdataLengthCheckBegin"),
    like    => qr/perfdataLengthCheckBegin/,
    waitfor => "perfdataLengthCheckBegin",
    maxwait => "120",
});

TestUtils::test_command({
    cmd => q(/bin/su - ) . $site . q( -c "influx -host 127.0.0.1 -port 8086 -username omdadmin -password omd -database nagflux -execute \"SELECT * FROM metrics WHERE command='perfdataLengthCheckEnd'\" | grep perfdataLengthCheckEnd"),
    like => qr/perfdataLengthCheckEnd/
});

# If there are no entries for the given query, influx cli prints nothing

TestUtils::test_command({
    cmd => q(/bin/su - ) . $site . q( -c "influx -host 127.0.0.1 -port 8086 -username omdadmin -password omd -database nagflux -execute \"SELECT * FROM metrics WHERE command='perfdataLengthCheckDiscarded'\" | wc -l | awk '{if (\$1 == 0) print \"DATABASE_CLEAN\"; else print \"DATABASE_HAS_DISCARDED_DATA\"}'"),
    like => qr/DATABASE_CLEAN/
});

###### TEST 3: Regex Filter

my $configFilter ='

[Filter]
    SpoolFileLineTerms = "check_ping"

';

# Add Filter To config and repeat test

TestUtils::test_command({
    cmd => "/bin/echo '$configFilter' | /bin/su - $site -c 'cat >> etc/nagflux/config.gcfg'"
});

TestUtils::test_command({ cmd => "/bin/su - $site -c 'omd restart nagflux' "});

# Test if database is up
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -t 60 -H 127.0.0.1 -p 8086 -u \"/query\" -P \"q=SHOW%20DATABASES\" -a \"omdadmin:omd\" -s \"nagflux\" '", like => '/HTTP OK:/' });

# Drop metrics table
TestUtils::test_command({
    cmd => q(/bin/su - ) . $site . q( -c "influx -host 127.0.0.1 -port 8086 -username omdadmin -password omd -database nagflux -execute \"DROP MEASUREMENT metrics\" "),
});

# only lines with check_ping on them should pass through the filter,
my $linesToFilter = sprintf("<<END
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::shouldpass	SERVICEDESC::test3	SERVICEPERFDATA::a used=4	SERVICECHECKCOMMAND::check_ping!-w 3: -c 4: -g :46 -l :48	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::shouldbefiltered	SERVICEDESC::range	SERVICEPERFDATA::a used=4;2;10	SERVICECHECKCOMMAND::check_ranges!-w 3: -c 4: -g :46 -l :48	SERVICESTATE::0	SERVICESTATETYPE::1
DATATYPE::SERVICEPERFDATA	TIMET::%d	HOSTNAME::shouldbefiltered	SERVICEDESC::test3	SERVICEPERFDATA::a used=4;2;10;1;4	SERVICECHECKCOMMAND::check_ranges!-w 3: -c 4: -g :46 -l :48	SERVICESTATE::0	SERVICESTATETYPE::1
END
",$timestamps[31],$timestamps[32],$timestamps[33]);

# Mock Nagios and write spoolfiles
TestUtils::test_command({ cmd => "/bin/su - $site -c 'cat > var/pnp4nagios/spool/ranges $linesToFilter'"});

#Wait for data in influxdb
TestUtils::test_url({
    url            => "http://127.0.0.1:8086/query?db=nagflux&q=SELECT%20*%20FROM%20metrics",
    auth           => "InfluxDB:omdadmin:omd",
    like           => [ "/test3/" ],
    waitfor        => "test3",
    maxwait        => "120",
});

#Test curl instead of check_http

TestUtils::test_command({
    cmd => q(/bin/su - ) . $site . q( -c "influx -host 127.0.0.1 -port 8086 -username omdadmin -password omd -database nagflux -execute \"SELECT * FROM metrics WHERE host='shouldpass'\" | wc -l | awk '{if (\$1 == 0) print \"NO_ENTRIES\"; else print \"ENTRIES_PRESENT\"}'"),
    like => qr/ENTRIES_PRESENT/
});

TestUtils::test_command({
    cmd => q(/bin/su - ) . $site . q( -c "influx -host 127.0.0.1 -port 8086 -username omdadmin -password omd -database nagflux -execute \"SELECT * FROM metrics WHERE host='shouldbefiltered'\" | wc -l | awk '{if (\$1 == 0) print \"NO_ENTRIES\"; else print \"ENTRIES_PRESENT\"}'"),
    like => qr/NO_ENTRIES/
});

#Clean up
TestUtils::test_command({ cmd => $omd_bin." stop $site" });
TestUtils::remove_test_site($site);
