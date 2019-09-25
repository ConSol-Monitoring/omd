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

plan( tests => 100 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

##################################################

# find out the ip address of this vm
my $this_ip = TestUtils::get_external_ip();
# create test host/service
TestUtils::prepare_obj_config('t/data/omd/testconf1', '/omd/sites/'.$site.'/etc/naemon/conf.d', $site);
ok(copy("t/data/downtime/test_conf1.cfg", "/omd/sites/$site/etc/naemon/conf.d/test.cfg"), "copy test config to site dir");

# update the ip address hof host down1
TestUtils::test_command({ cmd => "/usr/bin/env sed -i -e 's/#OMD_ADDRESS#/$this_ip/g' /omd/sites/$site/etc/naemon/conf.d/test.cfg" });

# create a host definition down1 with this address
# create a host definition down2 with another address
# create a host definition down3 with a DTAUTHKEY macro and another address
#
# execute some checks
my $tests = [
  { cmd => $omd_bin." config $site set CORE naemon" },
  { cmd => $omd_bin." config $site set DOWNTIMEAPI on" },
  { cmd => $omd_bin." start $site" },
  { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -t 60 -H localhost -a omdadmin:omd -u /$site/thruk/side.html -e 200'", like => '/HTTP OK:/' },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}
TestUtils::wait_for_file("/omd/sites/$site/tmp/run/live") or TestUtils::bail_out_clean("No need to test downtimes without livestatus connection");
my $ml = Monitoring::Livestatus->new(
  socket => "/omd/sites/$site/tmp/run/live"
);

#
# set host downtimes
#
# host1 -> ok, same ip
my $query = $ml->selectall_arrayref("GET hosts\nFilter: host_name = down1\nColumns: scheduled_downtime_depth host_name\n");
is($query->[0]->[0], 0, "host: down1 downtime does not yet exist");
my $dturl = "/$site/api/downtime?host=down1&comment=bla1&duration=1";
TestUtils::test_command({ cmd => sprintf("/bin/su - %s -c \"lib/monitoring-plugins/check_http -t 60 -H %s --onredirect=follow -u '%s' --ssl\"", $site, $this_ip, $dturl), like => '/HTTP OK:/' });
$query = $ml->selectall_arrayref("GET hosts\nFilter: host_name = down1\nColumns: scheduled_downtime_depth host_name\n");
is($query->[0]->[0], 1, "host: down1 downtime exists");
$query = $ml->selectall_arrayref("GET downtimes\nFilter: host_name = down1\nColumns: duration comment\n");
is($query->[0]->[0], 60, "host: down1 downtime is 1minute long");
like($query->[0]->[1], "/^bla1/", "host: down1 comment is correct");

# host2 -> fail, no token
$query = $ml->selectall_arrayref("GET hosts\nFilter: host_name = down2\nColumns: scheduled_downtime_depth host_name\n");
is($query->[0]->[0], 0, "host: down2 downtime does not yet exist");
$dturl = "/$site/api/downtime?host=down2&comment=bla1&duration=1";
TestUtils::test_command({ cmd => sprintf("/bin/su - %s -c \"lib/monitoring-plugins/check_http -t 60 -H %s --onredirect=follow -u '%s' --ssl\"", $site, $this_ip, $dturl), like => '/HTTP WARNING:.* 401/', exit => 1 });
$query = $ml->selectall_arrayref("GET hosts\nFilter: host_name = down2\nColumns: scheduled_downtime_depth host_name\n");
is($query->[0]->[0], 0, "host: down2 downtime must not exist");

# host3 -> fail, invalid token
$query = $ml->selectall_arrayref("GET hosts\nFilter: host_name = down3\nColumns: scheduled_downtime_depth host_name\n");
is($query->[0]->[0], 0, "host: down3 downtime does not yet exist");
$dturl = "/$site/api/downtime?host=down3&comment=bla1&duration=1&dtauthtoken=a62932a270bgeklauta21b80f8cff48";
TestUtils::test_command({ cmd => sprintf("/bin/su - %s -c \"lib/monitoring-plugins/check_http -t 60 -H %s --onredirect=follow -u '%s' --ssl\"", $site, $this_ip, $dturl), like => '/HTTP WARNING:.*401/', exit => 1 });
$query = $ml->selectall_arrayref("GET hosts\nFilter: host_name = omd-testsite\nColumns: scheduled_downtime_depth host_name\n");
is($query->[0]->[0], 0, "host: down3 downtime must not exist");

# down -> ok, token
$dturl = "/$site/api/downtime?host=down3&comment=bla1&duration=10&dtauthtoken=a62932a270b2e200d9ba21b80f8cff48";
TestUtils::test_command({ cmd => sprintf("/bin/su - %s -c \"lib/monitoring-plugins/check_http -t 60 -H %s --onredirect=follow -u '%s' --ssl\"", $site, $this_ip, $dturl), like => '/HTTP OK:/' });
$query = $ml->selectall_arrayref("GET hosts\nFilter: host_name = down3\nColumns: scheduled_downtime_depth host_name\n");
is($query->[0]->[0], 1, "host: down3 downtime exists");
$query = $ml->selectall_arrayref("GET downtimes\nFilter: host_name = down3\nColumns: duration comment\n");
is($query->[0]->[0], 600, "host: down3 downtime is 1minute long");
like($query->[0]->[1], "/^bla1/", "host: down3 comment is correct");

#
# Service downtimes
#
# down1/downsvc1 -> ok, same ip
$query = $ml->selectall_arrayref("GET services\nFilter: host_name = down1\nFilter: description = downsvc1\nColumns: scheduled_downtime_depth host_name description\n");
is($query->[0]->[0], 0, "service downtime does not yet exist: down1 - downsvc1");
$dturl = "/$site/api/downtime?host=down1&service=downsvc1&comment=bla1&duration=1";
TestUtils::test_command({ cmd => sprintf("/bin/su - %s -c \"lib/monitoring-plugins/check_http -t 60 -H %s --onredirect=follow -u '%s' --ssl\"", $site, $this_ip, $dturl), like => '/HTTP OK:/' });
$query = $ml->selectall_arrayref("GET services\nFilter: host_name = down1\nFilter: description = downsvc1\nColumns: scheduled_downtime_depth host_name description\n");
is($query->[0]->[0], 1, "service: down1 - downsvc1 downtime exists");

# down2/downsvc2 -> fail, no token, different ip
$dturl = "/$site/api/downtime?host=down2&service=downsvc2&comment=bla1&duration=1";
TestUtils::test_command({ cmd => sprintf("/bin/su - %s -c \"lib/monitoring-plugins/check_http -t 60 -H %s --onredirect=follow -u '%s' --ssl\"", $site, $this_ip, $dturl), like => '/HTTP WARNING:.* 401/', exit => 1 });
$query = $ml->selectall_arrayref("GET services\nFilter: host_name = down2\nFilter: description = downsvc2\nColumns: scheduled_downtime_depth host_name description\n");
is($query->[0]->[0], 0, "service: down2 - downsvc2 downtime must not exist");

# down3/downsvc3a with hostdt -> ok
$dturl = "/$site/api/downtime?host=down3&service=downsvc3a&comment=bla1&duration=1&dtauthtoken=a62932a270b2e200d9ba21b80f8cff48";
TestUtils::test_command({ cmd => sprintf("/bin/su - %s -c \"lib/monitoring-plugins/check_http -t 60 -H %s --onredirect=follow -u '%s' --ssl\"", $site, $this_ip, $dturl), like => '/HTTP OK:/' });
$query = $ml->selectall_arrayref("GET services\nFilter: host_name = down3\nFilter: description = downsvc3a\nColumns: scheduled_downtime_depth host_name description\n");
is($query->[0]->[0], 1, "service: down3 - downsvc3a downtime exists");

# down3/downsvc3b with hostdt -> fail
$dturl = "/$site/api/downtime?host=down3&service=downsvc3b&comment=bla1&duration=1&dtauthtoken=a62932a270b2e200d9ba21b80f8cff48";
TestUtils::test_command({ cmd => sprintf("/bin/su - %s -c \"lib/monitoring-plugins/check_http -t 60 -H %s --onredirect=follow -u '%s' --ssl\"", $site, $this_ip, $dturl), like => '/HTTP WARNING:.* 401/', exit => 1 });
$query = $ml->selectall_arrayref("GET services\nFilter: host_name = down3\nFilter: description = downsvc3b\nColumns: scheduled_downtime_depth host_name description\n");
is($query->[0]->[0], 0, "service: down3 - downsvc3b downtime must not exist");

# down3/downsvc3b with svcdt -> ok
$dturl = "/$site/api/downtime?host=down3&service=downsvc3b&comment=bla1&duration=1&dtauthtoken=a62932a270b2e200d9ba21b80f8cff00";
TestUtils::test_command({ cmd => sprintf("/bin/su - %s -c \"lib/monitoring-plugins/check_http -t 60 -H %s --onredirect=follow -u '%s' --ssl\"", $site, $this_ip, $dturl), like => '/HTTP OK:/' });
$query = $ml->selectall_arrayref("GET services\nFilter: host_name = down3\nFilter: description = downsvc3b\nColumns: scheduled_downtime_depth host_name description\n");
is($query->[0]->[0], 1, "service: down3 - downsvc3b downtime exists");

# delete downtime
$dturl = "/$site/api/downtime?host=down3&service=downsvc3b&dtauthtoken=a62932a270b2e200d9ba21b80f8cff00&delete=1";
TestUtils::test_command({ cmd => sprintf("/bin/su - %s -c \"lib/monitoring-plugins/check_http -t 60 -H %s --onredirect=follow -u '%s' --ssl\"", $site, $this_ip, $dturl), like => '/HTTP OK:/' });
$query = $ml->selectall_arrayref("GET services\nFilter: host_name = down3\nFilter: description = downsvc3b\nColumns: scheduled_downtime_depth host_name description\n");
is($query->[0]->[0], 0, "service: down3 - downsvc3b downtime must not exist");

##################################################
# cleanup test site
TestUtils::test_command({ cmd => $omd_bin." stop $site naemon", unlike => '/kill/i' });
TestUtils::test_command({ cmd => $omd_bin." stop $site" });
TestUtils::test_command({ cmd => sprintf("/bin/su - %s -c \"lib/monitoring-plugins/check_http -t 60 -H %s --onredirect=follow -u '%s' --ssl\"", $site, $this_ip, $dturl), like => '/HTTP CRITICAL:/', exit => 2 });
TestUtils::remove_test_site($site);
