#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use File::Copy;
use Monitoring::Livestatus;
use Data::Dumper;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
    use FindBin;
    use lib "$FindBin::Bin/lib/lib/perl5";
}

plan( tests => 93 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

##################################################

# find out the ip address of this vm
my $this_ip = TestUtils::get_external_ip();
# create test host/service
TestUtils::prepare_obj_config('t/data/omd/testconf1', '/omd/sites/'.$site.'/etc/nagios/conf.d', $site);
ok(copy("t/data/downtime/test_conf1.cfg", "/omd/sites/$site/etc/nagios/conf.d/test.cfg"), "copy test config to site dir");

# update the ip address hof host down1
TestUtils::test_command({ cmd => "/usr/bin/env sed -i -e 's/#OMD_ADDRESS#/$this_ip/g' /omd/sites/$site/etc/nagios/conf.d/test.cfg" });

# create a host definition down1 with this address
# create a host definition down2 with another address
# create a host definition down3 with a DTAUTHKEY macro and another address
#
# execute some checks
my $tests = [
  { cmd => $omd_bin." config $site set CORE naemon" },
  { cmd => $omd_bin." config $site set DOWNTIMEAPI on" },
  { cmd => $omd_bin." start $site" },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 60 -H localhost -a omdadmin:omd -u /$site/thruk/side.html -e 200'", like => '/HTTP OK:/' },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}
TestUtils::wait_for_file("/omd/sites/$site/tmp/run/live") or TestUtils::bail_out_clean("No need to test downtimes without livestatus connection");
my $ml = Monitoring::Livestatus->new(
  socket => "/omd/sites/$site/tmp/run/live"
);

#
# Host downtimes
#
my $query = $ml->selectall_arrayref("GET hosts\nFilter: host_name = down1\nColumns: scheduled_downtime_depth host_name\n");
$query = $ml->selectall_arrayref("GET hosts\nFilter: host_name = down1\nColumns: scheduled_downtime_depth host_name\n");
ok($query->[0]->[0] == 0);
# host1 -> ok, same ip
my $dturl = "/$site/api/downtime?host=down1&comment=bla1&duration=1";
TestUtils::test_command({ cmd => sprintf("/bin/su - %s -c \"lib/nagios/plugins/check_http -t 60 -H %s --onredirect=follow -u '%s' --ssl\"", $site, $this_ip, $dturl), like => '/HTTP OK:/' });
sleep 1;
$query = $ml->selectall_arrayref("GET hosts\nFilter: host_name = down1\nColumns: scheduled_downtime_depth host_name\n");
ok($query->[0]->[0] == 1);
sleep 61;
$query = $ml->selectall_arrayref("GET hosts\nFilter: host_name = down1\nColumns: scheduled_downtime_depth host_name\n");
ok($query->[0]->[0] == 0);

# host2 -> ok, same ip
$dturl = "/$site/api/downtime?host=down2&comment=bla1&duration=1";
TestUtils::test_command({ cmd => sprintf("/bin/su - %s -c \"lib/nagios/plugins/check_http -t 60 -H %s --onredirect=follow -u '%s' --ssl\"", $site, $this_ip, $dturl), like => '/HTTP WARNING:.* 401/', exit => 1 });
sleep 1;
$query = $ml->selectall_arrayref("GET hosts\nFilter: host_name = down2\nColumns: scheduled_downtime_depth host_name\n");
ok($query->[0]->[0] == 0);

# host3 -> ok, token
$dturl = "/$site/api/downtime?host=down3&comment=bla1&duration=1&dtauthtoken=a62932a270b2e200d9ba21b80f8cff48";
TestUtils::test_command({ cmd => sprintf("/bin/su - %s -c \"lib/nagios/plugins/check_http -t 60 -H %s --onredirect=follow -u '%s' --ssl\"", $site, $this_ip, $dturl), like => '/HTTP OK:/' });
$query = $ml->selectall_arrayref("GET hosts\nFilter: host_name = down3\nColumns: scheduled_downtime_depth host_name\n");
ok($query->[0]->[0] == 1);
sleep 61;
$query = $ml->selectall_arrayref("GET hosts\nFilter: host_name = down3\nColumns: scheduled_downtime_depth host_name\n");
ok($query->[0]->[0] == 0);

# host3 -> fail, invalid token
$dturl = "/$site/api/downtime?host=down3&comment=bla1&duration=1&dtauthtoken=a62932a270bgeklauta21b80f8cff48";
TestUtils::test_command({ cmd => sprintf("/bin/su - %s -c \"lib/nagios/plugins/check_http -t 60 -H %s --onredirect=follow -u '%s' --ssl\"", $site, $this_ip, $dturl), like => '/HTTP WARNING:.*401/', exit => 1 });
sleep 5;
$query = $ml->selectall_arrayref("GET hosts\nFilter: host_name = down3\nColumns: scheduled_downtime_depth host_name\n");
ok($query->[0]->[0] == 0);


#
# Service downtimes
#
# down1/downsvc1 -> ok, same ip
$dturl = "/$site/api/downtime?host=down1&service=downsvc1&comment=bla1&duration=1";
TestUtils::test_command({ cmd => sprintf("/bin/su - %s -c \"lib/nagios/plugins/check_http -t 60 -H %s --onredirect=follow -u '%s' --ssl\"", $site, $this_ip, $dturl), like => '/HTTP OK:/' });
sleep 1;
$query = $ml->selectall_arrayref("GET services\nFilter: host_name = down1\nFilter: description = downsvc1\nColumns: scheduled_downtime_depth host_name description\n");
ok($query->[0]->[0] == 1);
sleep 61;
$query = $ml->selectall_arrayref("GET services\nFilter: host_name = down1\nFilter: description = downsvc1\nColumns: scheduled_downtime_depth host_name description\n");
ok($query->[0]->[0] == 0);

# down2/downsvc2 -> fail, no token, different ip
$dturl = "/$site/api/downtime?host=down2&service=downsvc2&comment=bla1&duration=1";
TestUtils::test_command({ cmd => sprintf("/bin/su - %s -c \"lib/nagios/plugins/check_http -t 60 -H %s --onredirect=follow -u '%s' --ssl\"", $site, $this_ip, $dturl), like => '/HTTP WARNING:.* 401/', exit => 1 });
sleep 5;
$query = $ml->selectall_arrayref("GET services\nFilter: host_name = down2\nFilter: description = downsvc2\nColumns: scheduled_downtime_depth host_name description\n");
ok($query->[0]->[0] == 0);

# down3/downsvc3a with hostdt -> ok
$dturl = "/$site/api/downtime?host=down3&service=downsvc3a&comment=bla1&duration=1&dtauthtoken=a62932a270b2e200d9ba21b80f8cff48";
TestUtils::test_command({ cmd => sprintf("/bin/su - %s -c \"lib/nagios/plugins/check_http -t 60 -H %s --onredirect=follow -u '%s' --ssl\"", $site, $this_ip, $dturl), like => '/HTTP OK:/' });
sleep 1;
$query = $ml->selectall_arrayref("GET services\nFilter: host_name = down3\nFilter: description = downsvc3a\nColumns: scheduled_downtime_depth host_name description\n");
ok($query->[0]->[0] == 1);
sleep 61;
$query = $ml->selectall_arrayref("GET services\nFilter: host_name = down3\nFilter: description = downsvc3a\nColumns: scheduled_downtime_depth host_name description\n");
ok($query->[0]->[0] == 0);

# down3/downsvc3b with hostdt -> fail
$dturl = "/$site/api/downtime?host=down3&service=downsvc3b&comment=bla1&duration=1&dtauthtoken=a62932a270b2e200d9ba21b80f8cff48";
TestUtils::test_command({ cmd => sprintf("/bin/su - %s -c \"lib/nagios/plugins/check_http -t 60 -H %s --onredirect=follow -u '%s' --ssl\"", $site, $this_ip, $dturl), like => '/HTTP WARNING:.* 401/', exit => 1 });
sleep 1;
$query = $ml->selectall_arrayref("GET services\nFilter: host_name = down3\nFilter: description = downsvc3b\nColumns: scheduled_downtime_depth host_name description\n");
ok($query->[0]->[0] == 0);

# down3/downsvc3b with svcdt -> ok
$dturl = "/$site/api/downtime?host=down3&service=downsvc3b&comment=bla1&duration=1&dtauthtoken=a62932a270b2e200d9ba21b80f8cff00";
TestUtils::test_command({ cmd => sprintf("/bin/su - %s -c \"lib/nagios/plugins/check_http -t 60 -H %s --onredirect=follow -u '%s' --ssl\"", $site, $this_ip, $dturl), like => '/HTTP OK:/' });
sleep 1;
$query = $ml->selectall_arrayref("GET services\nFilter: host_name = down3\nFilter: description = downsvc3b\nColumns: scheduled_downtime_depth host_name description\n");
ok($query->[0]->[0] == 1);
sleep 61;
$query = $ml->selectall_arrayref("GET services\nFilter: host_name = down3\nFilter: description = downsvc3b\nColumns: scheduled_downtime_depth host_name description\n");
ok($query->[0]->[0] == 0);


$tests = [
  { cmd => $omd_bin." stop $site naemon", unlike => '/kill/i' },
  { cmd => $omd_bin." stop $site" },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}
TestUtils::test_command({ cmd => sprintf("/bin/su - %s -c \"lib/nagios/plugins/check_http -t 60 -H %s --onredirect=follow -u '%s' --ssl\"", $site, $this_ip, $dturl), like => '/HTTP CRITICAL:/', exit => 2 });

##################################################
# cleanup test site
TestUtils::remove_test_site($site);

