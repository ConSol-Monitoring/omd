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

plan( tests => 129 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");
my $auth    = 'OMD Monitoring Site '.$site.':omdadmin:omd';
my $curl    = '/usr/bin/curl -v --user omdadmin:omd --noproxy \* ';
my $ip      = TestUtils::get_external_ip();

# create test host/service
TestUtils::prepare_obj_config('t/data/omd/testconf1', '/omd/sites/'.$site.'/etc/naemon/conf.d', $site);
TestUtils::test_command({ cmd => "/usr/bin/env sed -i -e 's/^perfdata_file_processing_interval = 15/perfdata_file_processing_interval = 2/g' -e 's/^sleep_time = 15/sleep_time = 2/g' /opt/omd/sites/$site/etc/pnp4nagios/npcd.cfg" });

TestUtils::test_command({ cmd => $omd_bin." config $site set GRAFANA on" });
TestUtils::test_command({ cmd => $omd_bin." start $site", like => '/Starting Grafana...OK/' });

# schedule forced check
TestUtils::test_command({ cmd => "/bin/su - $site -c './lib/monitoring-plugins/check_http -H localhost -a omdadmin:omd -u /$site/thruk/cgi-bin/cmd.cgi -e 200 -P \"cmd_typ=96&cmd_mod=2&host=omd-$site&start_time=2010-11-06+09%3A46%3A02&force_check=on&btnSubmit=Commit\" -r \"Your command request was successfully submitted\"'", like => '/HTTP OK:/' });
TestUtils::wait_for_file("/omd/sites/$site/var/pnp4nagios/perfdata/omd-$site/_HOST_.xml");

#grafana interface
TestUtils::test_command({ cmd => "/bin/su - $site -c 'cat var/log/grafana/grafana.log'", like => '/HTTP Server Listen/', waitfor => 'HTTP\ Server\ Listen', maxwait => 180 });
TestUtils::test_url({ url => 'http://localhost/'.$site.'/grafana/', waitfor => '<title>Grafana<\/title>', auth => $auth });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/monitoring-plugins/check_http -t 60 -H 127.0.0.1 -p 8003 -k \"X-WEBAUTH-USER: omdadmin\" -s \"<title>Grafana</title>\"'", like => '/HTTP OK:/', waitfor => 'HTTP\ OK:' });
TestUtils::test_command({ cmd => "/omd/sites/$site/lib/monitoring-plugins/check_http -t 60 -H localhost -a omdadmin:omd -u '/$site/grafana/' -s '\"login\":\"omdadmin\"'", like => '/HTTP OK:/', waitfor => 'HTTP\ OK:' });

#grafana interface with ssl
TestUtils::test_command({ cmd => $omd_bin." stop $site", like => '/Stopping Grafana/' });
TestUtils::test_command({ cmd => $omd_bin." config $site set APACHE_MODE ssl", like => '/^$/' });
TestUtils::test_command({ cmd => $omd_bin." start $site", like => '/Starting Grafana/' });
TestUtils::restart_system_apache();
TestUtils::test_command({ cmd => "/bin/su - $site -c 'cat var/log/grafana/grafana.log'", like => '/HTTP Server Listen/', waitfor => 'HTTP\ Server\ Listen', maxwait => 180 });
TestUtils::test_command({ cmd => "/omd/sites/$site/lib/monitoring-plugins/check_http -t 60 -H localhost -S -a omdadmin:omd -u '/$site/grafana/' -s '\"login\":\"omdadmin\"'", like => '/HTTP OK:/', waitfor => 'HTTP\ OK:' });

TestUtils::test_command({ cmd => $omd_bin." stop $site" });

#grafana interface with ssl and thruk cookie auth
my $sessionid = TestUtils::create_fake_cookie_login($site);
TestUtils::test_command({ cmd => $omd_bin." config $site set THRUK_COOKIE_AUTH on", like => '/^$/' });
TestUtils::test_command({ cmd => $omd_bin." start $site", like => '/Starting Grafana/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'cat var/log/grafana/grafana.log'", like => '/HTTP Server Listen/', waitfor => 'HTTP\ Server\ Listen', maxwait => 180 });
TestUtils::test_command({ cmd => "/omd/sites/$site/lib/monitoring-plugins/check_http -t 60 -H localhost -S -k 'Cookie: thruk_auth=$sessionid' -u '/$site/grafana/' -s '\"login\":\"omdadmin\"'", like => '/HTTP OK:/', waitfor => 'HTTP\ OK:' });
TestUtils::test_command({ cmd => "/omd/sites/$site/lib/monitoring-plugins/check_http -t 60 -H localhost -S -k 'Cookie: thruk_auth=$sessionid' -u '/$site/grafana/api/datasources/proxy/1/index.php/api/hosts' -vv -s '[{\"name\":\"omd-testsite\"}]'", like => '/HTTP OK:/' });

#grafana interface with http and thruk cookie auth
TestUtils::test_command({ cmd => $omd_bin." stop $site" });
TestUtils::test_command({ cmd => $omd_bin." config $site set APACHE_MODE own", like => '/^$/' });
TestUtils::restart_system_apache();
TestUtils::test_command({ cmd => $omd_bin." start $site", like => '/Starting Grafana/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'cat var/log/grafana/grafana.log'", like => '/HTTP Server Listen/', waitfor => 'HTTP\ Server\ Listen', maxwait => 180 });
TestUtils::test_command({ cmd => "/omd/sites/$site/lib/monitoring-plugins/check_http -t 60 -H localhost -k 'Cookie: thruk_auth=$sessionid' -u '/$site/grafana/' -s '\"login\":\"omdadmin\"'", like => '/HTTP OK:/', waitfor => 'HTTP\ OK:'  });


# make sure grafana listens to localhost only
# first test against localhost and make sure it works
TestUtils::test_command({ cmd => "/bin/su - $site -c '$curl \"http://127.0.0.1:8003\" -H \"X-WEBAUTH-USER: omdadmin\" '",
                          errlike => ['/200 OK/'], 
                          like  => ['/"login":"omdadmin"/'],
                       });
# then test external ip and make sure it doesnt work
TestUtils::test_command({ cmd => "/bin/su - $site -c '$curl \"http://$ip:8003/\" -H \"X-WEBAUTH-USER: omdadmin\" '",
                          errlike => ['/(Failed to connect|Connection refused)/'], 
                          unlike  => ['/"login":"omdadmin"/'],
                          exit    => undef,
                       });

TestUtils::test_command({ cmd => $omd_bin." stop $site" });
TestUtils::remove_test_site($site);

