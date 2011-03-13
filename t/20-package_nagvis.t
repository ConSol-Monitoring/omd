#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
    use FindBin;
    use lib "$FindBin::Bin/lib/lib/perl5";
}

plan( tests => 232 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");
my $auth    = 'OMD Monitoring Site '.$site.':omdadmin:omd';
# Create code to find this out
my $version = '1.5.8';

#TestUtils::test_command({ cmd => "/d1/nagvis/mache" });

##################################################
# Prepare the site for testing...

TestUtils::test_command({ cmd => $omd_bin." config $site set DEFAULT_GUI nagvis" });
TestUtils::test_command({ cmd => $omd_bin." start $site" });

##################################################
# Some checks to ensure the basic functionality

my $tests = [
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 30 -H localhost -u /$site/nagvis -e 401'",                  like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 30 -H localhost -a omdadmin:omd -u /$site/nagvis -e 301'",  like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 30 -H localhost -a omdadmin:omd -u /$site/nagvis/ -e 302'", like => '/HTTP OK:/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 30 -H localhost -a omdadmin:omd -u /$site/nagvis/frontend/nagvis-js/index.php -e 302'", like => '/HTTP OK:/' },
];

for my $test (@{$tests}) {
    TestUtils::test_command($test);
}

##################################################
# User interface URL tests

my $urls = [
  # OMD welcome page in NagVis mode
  url({ url => "", like => '/<title>NagVis '.$version.'<\/title>/' }),

	# default pages
  url({ url  => "/nagvis/frontend/nagvis-js/index.php",
	      like => '/<title>NagVis '.$version.'<\/title>/' }),
  url({ url  => "/nagvis/frontend/wui/index.php",
        like => [ '/<title>NagVis '.$version.' &rsaquo; WUI<\/title>/',
                  '/Welcome to the NagVis WUI/' ], 'skip_html_lint' => 1 }),
  url({ url  => "/nagvis/frontend/nagvis-js/index.php?mod=Info",
        like => '/NagVis Support Information<\/title>/' }),
  url({ url  => "/nagvis/frontend/nagvis-js/index.php?mod=Map&act=view&show=demo",
        like => '/, \'demo\'/', 'skip_html_lint' => 1 }),
  url({ url  => "/nagvis/frontend/wui/index.php?mod=Map&act=edit&show=demo",
        like => [ '/WUI<\/title>/', '/var mapname = \'demo\';/' ], 'skip_html_lint' => 1 }),

	# Old redirects to maps
  url({ url  => "/nagvis/index.php?map=demo",
        like => '/, \'demo\'/', 'skip_html_lint' => 1 }),
  url({ url  => "/nagvis/config.php?map=demo",
        like => [ '/WUI<\/title>/', '/var mapname = \'demo\';/' ], 'skip_html_lint' => 1 }),

  # Ajax fetched dialogs
	# FIXME: only valid when not using trusted auth:
	#api_url({ url  => '/nagvis/server/core/ajax_handler.php?mod=ChangePassword&act=view',
	#          like => [ '/{"code":"/', '/changePasswordForm/' ]}),
	api_url({ url  => '/nagvis/server/core/ajax_handler.php?mod=UserMgmt&act=view',
            like => [ '/Create User/', '/"code":"/' ]}),
	api_url({ url  => '/nagvis/server/core/ajax_handler.php?mod=RoleMgmt&act=view',
            like => [ '/Create Role/', '/"code":"/' ]}),

  # Language switch
	url({ url  => "/nagvis/frontend/nagvis-js/index.php?lang=de_DE",
        like => '/Sprache w&auml;hlen/'}),
];

# perform tests
for my $url ( @{$urls} ) {
    TestUtils::test_url($url);
}

##################################################
# AJAX API tests

# /nagvis/server/core/ajax_handler.php?mod=General&act=getCfgFileAges&f[]=mainCfg
# {"mainCfg":1296327919} => mtime of <site>/etc/nagvis/nagvis.ini.php
#
# 1. Test the file age returned by NagVis and compare it with the mtime fetched by this test
# 2. Touch the file and check if the API returns the new age
# 3. Do the same with a map config file
# 4. Do the same with an automap config file
TestUtils::test_url(
  api_url({ url  => '/nagvis/server/core/ajax_handler.php?mod=General&act=getCfgFileAges&f[]=mainCfg',
            like => '/^{"mainCfg":'.site_mtime($site, 'etc/nagvis/nagvis.ini.php').'}$/' })
);

TestUtils::test_url(
  api_url({ url  => '/nagvis/server/core/ajax_handler.php?mod=General&act=getCfgFileAges&f[]=mainCfg',
            like => '/^{"mainCfg":'.site_touch($site, 'etc/nagvis/nagvis.ini.php').'}$/' })
);

TestUtils::test_url(
  api_url({ url  => '/nagvis/server/core/ajax_handler.php?mod=General&act=getCfgFileAges&f[]=mainCfg&m[]=demo',
            like => '/^{"mainCfg":'.site_mtime($site, 'etc/nagvis/nagvis.ini.php').',"demo":'.site_mtime($site, 'etc/nagvis/maps/demo.cfg').'}$/' })
);

TestUtils::test_url(
  api_url({ url  => '/nagvis/server/core/ajax_handler.php?mod=General&act=getCfgFileAges&f[]=mainCfg&m[]=demo',
            like => '/^{"mainCfg":'.site_mtime($site, 'etc/nagvis/nagvis.ini.php').',"demo":'.site_touch($site, 'etc/nagvis/maps/demo.cfg').'}$/' })
);

TestUtils::test_url(
  api_url({ url  => '/nagvis/server/core/ajax_handler.php?mod=General&act=getCfgFileAges&f[]=mainCfg&am[]=__automap',
            like => '/^{"mainCfg":'.site_mtime($site, 'etc/nagvis/nagvis.ini.php').',"__automap":'.site_mtime($site, 'etc/nagvis/automaps/__automap.cfg').'}$/' })
);

TestUtils::test_url(
  api_url({ url  => '/nagvis/server/core/ajax_handler.php?mod=General&act=getCfgFileAges&f[]=mainCfg&am[]=__automap',
            like => '/^{"mainCfg":'.site_mtime($site, 'etc/nagvis/nagvis.ini.php').',"__automap":'.site_touch($site, 'etc/nagvis/automaps/__automap.cfg').'}$/' })
);

# /nagvis/server/core/ajax_handler.php?mod=General&act=getStateProperties
# {"UNREACHABLE":{"normal":"9","ack":"5","ack_bgcolor":"","downtime":"5","downtime_bgcolor":"","bgcolor":"#F1811B","color":"#F1811B","sound":"std_unreachable.mp3"},"DOWN":{"normal":"8","ack":"5","ack_bgcolor":"","downtime":"5","downtime_bgcolor":"","bgcolor":"#FF0000","color":"#FF0000","sound":"std_down.mp3"},"CRITICAL":{"normal":"7","ack":"5","ack_bgcolor":"","downtime":"5","downtime_bgcolor":"","bgcolor":"#FF0000","color":"#FF0000","sound":"std_critical.mp3"},"WARNING":{"normal":"6","ack":"4","ack_bgcolor":"","downtime":"4","downtime_bgcolor":"","bgcolor":"#FFFF00","color":"#FFFF00","sound":"std_warning.mp3"},"UNKNOWN":{"normal":"3","ack":"2","ack_bgcolor":"","downtime":"2","downtime_bgcolor":"","bgcolor":"#FFCC66","color":"#FFCC66","sound":""},"ERROR":{"normal":"3","ack":"2","ack_bgcolor":"","downtime":"2","downtime_bgcolor":"","bgcolor":"#0000FF","color":"#0000FF","sound":""},"UP":{"normal":"1","downtime":"1","bgcolor":"#00FF00","color":"#00FF00","sound":""},"OK":{"normal":"1","downtime":"1","bgcolor":"#00FF00","color":"#00FF00","sound":""},"PENDING":{"normal":"0","downtime":"0","bgcolor":"#C0C0C0","color":"#C0C0C0","sound":""}}
TestUtils::test_url(
  api_url({ url  => '/nagvis/server/core/ajax_handler.php?mod=General&act=getStateProperties',
            like => [ '/"UNREACHABLE"/', '/"UNKNOWN"/' ]})
);

# /nagvis/server/core/ajax_handler.php?mod=General&act=getHoverTemplate&name[]=default
# [{"name":"default","code":"<...>"}]
TestUtils::test_url(
  api_url_list({ url  => '/nagvis/server/core/ajax_handler.php?mod=General&act=getHoverTemplate&name[]=default',
                 like => [ '/"name":"default","code":/' ]})
);

# /nagvis/server/core/ajax_handler.php?mod=General&act=getContextTemplate&name[]=default
# [{"name":"default","code":"<...>"}]
TestUtils::test_url(
  api_url_list({ url  => '/nagvis/server/core/ajax_handler.php?mod=General&act=getContextTemplate&name[]=default',
                 like => [ '/"name":"default","code":/' ]})
);

# /nagvis/server/core/ajax_handler.php?mod=Map&act=getMapProperties&show=demo
# {"map_name":"demo","alias":"demo","background_image":"\/nagvis\/userfiles\/images\/maps\/nagvis-demo.png","background_color":"transparent","favicon_image":"\/nagvis\/frontend\/nagvis-js\/images\/internal\/favicon.png","page_title":"demo ([SUMMARY_STATE]) :: NagVis 1.5.7","event_background":"0","event_highlight":"1","event_highlight_interval":"500","event_highlight_duration":"10000","event_log":"0","event_log_level":"info","event_log_height":"100","event_log_hidden":1,"event_scroll":"1","event_sound":"1","in_maintenance":"0"}
TestUtils::test_url(
  api_url({ url  => '/nagvis/server/core/ajax_handler.php?mod=Map&act=getMapProperties&show=demo',
            like => [ '/"map_name":"demo",/' ]})
);

# /nagvis/server/core/ajax_handler.php?mod=Map&act=getMapObjects&show=demo
# FIXME: Add sepecial tests for object states here using the test backend
TestUtils::test_url(
  api_url_list({ url  => '/nagvis/server/core/ajax_handler.php?mod=Map&act=getMapObjects&show=demo',
                 like => [ '/"alias":"demo"/' ]})
);

# /nagvis/server/core/ajax_handler.php?mod=Map&act=getObjectStates&show=demo&ty=state&i[]=2&t[]=host&n1[]=host-down-hard&n2[]=
# FIXME: Add sepecial tests for object states here using the test backend
TestUtils::test_url(
  api_url_list({ url  => '/nagvis/server/core/ajax_handler.php?mod=Map&act=getObjectStates&show=demo&ty=state&i[]=1&t[]=host&n1[]=localhost',
                 like => [ '/{"state":/' ]})
);

###############################################################################
# OVERVIEW
###############################################################################
# /nagvis/server/core/ajax_handler.php?mod=Overview&act=getOverviewProperties
# {"cellsperrow":4,"showautomaps":1,"showmaps":1,"showgeomap":0,"showmapthumbs":0,"showrotations":1,"page_title":"NagVis 1.5.7","favicon_image":"\/nagvis\/frontend\/nagvis-js\/images\/internal\/favicon.png","background_color":"#ffffff","lang_mapIndex":"Map Index","lang_automapIndex":"Automap Index","lang_rotationPools":"Rotation Pools","event_log":0,"event_log_level":"info","event_log_height":100,"event_log_hidden":1}
TestUtils::test_url(
  api_url({ url  => '/nagvis/server/core/ajax_handler.php?mod=Overview&act=getOverviewProperties',
            like => [ '/"showautomaps":1,"showmaps":1,"showgeomap":0,"showmapthumbs":0,"showrotations":1/', ]})
);

# /nagvis/server/core/ajax_handler.php?mod=Overview&act=getOverviewMaps
TestUtils::test_url(
  api_url_list({ url  => '/nagvis/server/core/ajax_handler.php?mod=Overview&act=getOverviewMaps',
                 like => [ '/"alias":/', ]})
);

# /nagvis/server/core/ajax_handler.php?mod=Overview&act=getOverviewAutomaps
TestUtils::test_url(
  api_url_list({ url  => '/nagvis/server/core/ajax_handler.php?mod=Overview&act=getOverviewAutomaps',
                 like => [ '/"alias":/', ]})
);

# /nagvis/server/core/ajax_handler.php?mod=Overview&act=getOverviewRotations
TestUtils::test_url(
  api_url_list({ url  => '/nagvis/server/core/ajax_handler.php?mod=Overview&act=getOverviewRotations',
                 like => [ '/"name":"demo",/', ]})
);

# /nagvis/server/core/ajax_handler.php?mod=General&act=getObjectStates&ty=state&i[]=automap-0&t[]=automap&n1[]=__automap&n2[]=
TestUtils::test_url(
  api_url_list({ url  => '/nagvis/server/core/ajax_handler.php?mod=General&act=getObjectStates&ty=state&i[]=automap-0&t[]=automap&n1[]=__automap',
                 like => [ '/"state":"/', ]})
);

###############################################################################
# AUTOMAP
###############################################################################
# /nagvis/server/core/ajax_handler.php?mod=AutoMap&act=getAutomapProperties&show=__automap&childLayers=2
TestUtils::test_url(
  api_url({ url  => '/nagvis/server/core/ajax_handler.php?mod=AutoMap&act=getAutomapProperties&show=__automap&childLayers=2',
            like => [ '/"map_name":"__automap","alias":"Default Automap"/', ]})
);

# /nagvis/server/core/ajax_handler.php?mod=AutoMap&act=getAutomapObjects&show=__automap&childLayers=2
TestUtils::test_url(
  api_url_list({ url  => '/nagvis/server/core/ajax_handler.php?mod=AutoMap&act=getAutomapObjects&show=__automap&childLayers=2',
                 like => [ '/"alias":"Default Automap"/', ]})
);

# /nagvis/server/core/ajax_handler.php?mod=AutoMap&act=getObjectStates&show=__automap&ty=state&i[]=0&t[]=host&n1[]=localhost&n2[]=&childLayers=2
# FIXME: Test the different automap params
TestUtils::test_url(
  api_url_list({ url  => '/nagvis/server/core/ajax_handler.php?mod=AutoMap&act=getObjectStates&show=__automap&ty=state&i[]=0&t[]=host&n1[]=localhost&n2[]=&childLayers=2',
                 like => [ '/"state":"/', ]})
);

##################################################
# cleanup test site
TestUtils::remove_test_site($site);


##################################################
# HELPER FUNCTIONS
#   maybe move some of them to the general code one day

sub url {
    my $url = shift;
    $url->{'url'} = "http://localhost/".$site.$url->{'url'};
    $url->{'auth'}   = $auth;
    $url->{'unlike'} = [ '/internal server error/' ];
    return $url;
}
sub api_url {
    my $url = url(shift);
    my $obj_match = shift;
    if(!defined $obj_match) {
        $obj_match = '/^{.*}$/';
		}

    $url->{'no_html_lint'} = 1;

    # Add default AJAX API tests
    my $def_like = [ $obj_match ];
    if(defined $url->{'like'}) {
        if(ref $url->{'like'} ne 'ARRAY') {
            $url->{'like'} = [ $url->{'like'} ];
				}
        push(@{$url->{'like'}}, @{$def_like});
    } else {
        $url->{'like'} = $def_like;
		}
    return $url;
}
sub api_url_list {
	return api_url(shift, '/^\[.*\]$/')
}

=head2 site_touch

  Touches a given site file to modify the last access and modification
  time of a given file. The path is given relative to the sites base dir.
  The functions returns the touch time as unix timestamp.

=cut
sub site_touch {
    my $site = shift;
    my $path = shift;
    my $now = time;
    utime $now, $now, '/omd/sites/'.$site.'/'.$path;
    return $now;
}


=head2 site_mtime

  Returns the mtime for a file in the given site.
  The path is given as relative path to the sites base directory.
  The time is returned as unix timestamp.

=cut
sub site_mtime {
    my $site = shift;
    my $path = shift;
    return (stat '/omd/sites/'.$site.'/'.$path)[9];
}
