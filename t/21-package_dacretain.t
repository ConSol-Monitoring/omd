#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use File::Copy qw(copy);
use Monitoring::Livestatus;
use Data::Dumper;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
    use FindBin;
    use lib "$FindBin::Bin/lib/lib/perl5";
}

my $FULL = 't/data/dacretain/dacretain_full.cfg';
my $PARTIAL = 't/data/dacretain/dacretain_partial.cfg';
use constant HR => { Slice => {} };


##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

# create test config
ok(copy($FULL, "/omd/sites/$site/etc/naemon/conf.d/test.cfg"), "copy full test config to site dir");

# configure the site
my $tests = [
  { cmd => $omd_bin." config $site set CORE naemon" },
  { cmd => $omd_bin." config $site set DACRETAIN on" },
  { cmd => $omd_bin." start $site", errlike => '/init_db/' },
  { cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -t 60 -H localhost -a omdadmin:omd -u /$site/thruk/side.html -e 200'", like => '/HTTP OK:/' },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}
TestUtils::wait_for_file("/omd/sites/$site/tmp/run/live") or TestUtils::bail_out_clean("Livestatus not available");
my $ml = Monitoring::Livestatus->new(
  socket => "/omd/sites/$site/tmp/run/live"
);

my $t = time;
# force checks of everything (no pending)
for(1..6) {
    $ml->do("COMMAND [$t] SCHEDULE_FORCED_HOST_SVC_CHECKS;down$_;$t");
    $ml->do("COMMAND [$t] SCHEDULE_FORCED_HOST_CHECK;down$_;$t");
}
$ml->do("COMMAND [$t] SCHEDULE_FORCED_HOST_SVC_CHECKS;up1;$t");
$ml->do("COMMAND [$t] SCHEDULE_FORCED_HOST_CHECK;up1;$t");

# wait till there are no pending hosts / services
for(1..30) {
    last if($ml->selectscalar_value("GET hosts\nStats: has_been_checked = 0\n") == 0 && $ml->selectscalar_value("GET services\nStats: has_been_checked = 0\n") == 0);
    sleep 1;
}

# Check if the expected number of services/hosts are down
is( $ml->selectscalar_value("GET hosts\nStats: state = 1\n"), 6, "6 hosts are down");
is( $ml->selectscalar_value("GET services\nStats: state = 2\n"), 18, "18 services are critical");
is( $ml->selectscalar_value("GET hosts\nStats: state = 0\n"), 1, "1 hosts is up");
is( $ml->selectscalar_value("GET services\nStats: state = 0\n"), 3, "3 services are OK");

# Add downtimes and acknowledgements
$ml->do("COMMAND [$t] ACKNOWLEDGE_HOST_PROBLEM;down3;1;1;1;naemonadmin;down3 ack");
$ml->do("COMMAND [$t] ACKNOWLEDGE_HOST_PROBLEM;down5;1;1;1;naemonadmin;down5 ack");
$ml->do("COMMAND [$t] ACKNOWLEDGE_SVC_PROBLEM;down4;S1;1;1;1;naemonadmin;S1 ack");
$ml->do("COMMAND [$t] ACKNOWLEDGE_SVC_PROBLEM;down3;S2;1;1;1;naemonadmin;S2 ack");
$ml->do("COMMAND [$t] ACKNOWLEDGE_SVC_PROBLEM;down2;S1;1;1;1;naemonadmin;S1 ack");
$ml->do("COMMAND [$t] ACKNOWLEDGE_SVC_PROBLEM;down1;S3;1;1;1;naemonadmin;S3 ack");
$ml->do("COMMAND [$t] SCHEDULE_HOST_DOWNTIME;up1;@{[ time + 3000 ]};@{[ time + 6000 ]};1;0;100;naemonadmin;down1");
$ml->do("COMMAND [$t] SCHEDULE_HOST_DOWNTIME;down1;@{[ time + 3000 ]};@{[ time + 6000 ]};1;0;100;naemonadmin;down1");
$ml->do("COMMAND [$t] SCHEDULE_SVC_DOWNTIME;up1;S1;@{[ time + 3000 ]};@{[ time + 6000 ]};1;0;100;naemonadmin;S1");
$ml->do("COMMAND [$t] SCHEDULE_SVC_DOWNTIME;down3;S3;@{[ time + 3000 ]};@{[ time + 6000 ]};1;0;100;naemonadmin;S3");
$ml->do("COMMAND [$t] SCHEDULE_SVC_DOWNTIME;down3;S1;@{[ time + 3000 ]};@{[ time + 6000 ]};1;0;100;naemonadmin;S1");
$ml->do("COMMAND [$t] SCHEDULE_SVC_DOWNTIME;down2;S2;@{[ time + 3000 ]};@{[ time + 6000 ]};1;0;100;naemonadmin;S2");

sleep 1;

# Specify the expected number of comments/acknowledgements
my $fulltests = sub {
    is($ml->selectscalar_value("GET comments\nStats: is_service = 0\n"), 4, "4 host comments");
    is($ml->selectscalar_value("GET comments\nStats: is_service = 1\n"), 8, "8 service comments");
    is($ml->selectscalar_value("GET hosts\nStats: acknowledged = 1\n"), 2, "2 acked hosts");
    is($ml->selectscalar_value("GET services\nStats: acknowledged = 1\n"), 4, "4 acked services");
    is($ml->selectscalar_value("GET downtimes\nStats: is_service = 0\n"), 2, "2 host downtimes");
    is($ml->selectscalar_value("GET downtimes\nStats: is_service = 1\n"), 4, "4 service downtimes");
};

# check if all the downtimes/comments/acks are there
&{$fulltests}();

# load a config with missing hosts/services
ok(copy($PARTIAL, "/omd/sites/$site/etc/naemon/conf.d/test.cfg"), "copy partial test config to site dir");
TestUtils::test_command({ cmd => $omd_bin." reload $site naemon",  errlike => "/dacretain:/" });

# Check if the number of comments is lower than before
is($ml->selectscalar_value("GET comments\nStats: is_service = 0\n"), 1, "1 host comments");
is($ml->selectscalar_value("GET comments\nStats: is_service = 1\n"), 3, "3 service comments");

# restore the old config
ok(copy($FULL, "/omd/sites/$site/etc/naemon/conf.d/test.cfg"), "restore full test config to site dir");
TestUtils::test_command({ cmd => $omd_bin." reload $site naemon",  errlike => "/dacretain:/" });

# is everything back?
&{$fulltests}();

##################################################
# cleanup test site
TestUtils::test_command({ cmd => $omd_bin." stop $site naemon", unlike => '/kill/i', errlike => "/dacretain:/" });
TestUtils::test_command({ cmd => $omd_bin." stop $site", errlike => "/dacretain:/" });
TestUtils::test_command({ cmd => $omd_bin." config $site set DACRETAIN off" });
TestUtils::remove_test_site($site);

done_testing();
__END__
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

