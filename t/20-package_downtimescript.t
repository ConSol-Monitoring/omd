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

plan( tests => 64 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

##################################################

# find out the ip address of this vm
my $this_ip = TestUtils::get_external_ip();
diag("ip of this test omd is ".$this_ip);
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

my $query = $ml->selectall_arrayref("GET hosts\nFilter: host_name = down1\nColumns: scheduled_downtime_depth host_name\n");
# GET downtimes author;comment;duration host_name
$query = $ml->selectall_arrayref("GET hosts\nFilter: host_name = down1\nColumns: scheduled_downtime_depth host_name\n");
ok($query->[0]->[0] == 0);

my $dturl = "/$site/api/downtime?host=down1&comment=bla1&duration=1";
diag("downtime command is ".$dturl);

# downtime 1 minute for down1 -> must succeed with 200
TestUtils::test_command({ cmd => sprintf("/bin/su - %s -c \"lib/nagios/plugins/check_http -t 60 -H %s --onredirect=follow -u '%s' --ssl\"", $site, $this_ip, $dturl), like => '/HTTP OK:/' });
# -> down1 must be in scheduled downtime, check with thruk/livestatus
sleep 1;
$query = $ml->selectall_arrayref("GET hosts\nFilter: host_name = down1\nColumns: scheduled_downtime_depth host_name\n");
ok($query->[0]->[0] == 1);
# sleep 61
# -> down1 must not be in scheduled downtime, check with thruk/livestatus
#
sleep 61;
$query = $ml->selectall_arrayref("GET hosts\nFilter: host_name = down1\nColumns: scheduled_downtime_depth host_name\n");
ok($query->[0]->[0] == 0);

$dturl = "/$site/api/downtime?host=down2&comment=bla1&duration=1";
diag("downtime command is ".$dturl);

# downtime 1 minute for down2 -> must fail with 401
TestUtils::test_command({ cmd => sprintf("/bin/su - %s -c \"lib/nagios/plugins/check_http -t 60 -H %s --onredirect=follow -u '%s' --ssl\"", $site, $this_ip, $dturl), like => '/HTTP WARNING:.* 401/', exit => 1 });
# -> down2 must not be in scheduled downtime, check with thruk/livestatus
sleep 1;
$query = $ml->selectall_arrayref("GET hosts\nFilter: host_name = down2\nColumns: scheduled_downtime_depth host_name\n");
ok($query->[0]->[0] == 0);

$dturl = "/$site/api/downtime?host=down3&comment=bla1&duration=1&dtauthtoken=a62932a270b2e200d9ba21b80f8cff48";
diag("downtime command is ".$dturl);

# downtime 1 minute for down3 with correct token -> must succeed with 200
TestUtils::test_command({ cmd => sprintf("/bin/su - %s -c \"lib/nagios/plugins/check_http -t 60 -H %s --onredirect=follow -u '%s' --ssl\"", $site, $this_ip, $dturl), like => '/HTTP OK:/' });
# -> down3 must be in scheduled downtime, check with thruk/livestatus
$query = $ml->selectall_arrayref("GET hosts\nFilter: host_name = down3\nColumns: scheduled_downtime_depth host_name\n");
ok($query->[0]->[0] == 1);
# sleep 61
# -> down3 must not be in scheduled downtime, check with thruk/livestatus
sleep 61;
$query = $ml->selectall_arrayref("GET hosts\nFilter: host_name = down3\nColumns: scheduled_downtime_depth host_name\n");
ok($query->[0]->[0] == 0);
#

$dturl = "/$site/api/downtime?host=down3&comment=bla1&duration=1&dtauthtoken=a62932a270bgeklauta21b80f8cff48";
diag("downtime command is ".$dturl);


# downtime 1 minute for down3 with invalid token -> must fail with 401
TestUtils::test_command({ cmd => sprintf("/bin/su - %s -c \"lib/nagios/plugins/check_http -t 60 -H %s --onredirect=follow -u '%s' --ssl\"", $site, $this_ip, $dturl), like => '/HTTP WARNING:.*401/', exit => 1 });
# -> down3 must not be in scheduled downtime, check with thruk/livestatus

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

