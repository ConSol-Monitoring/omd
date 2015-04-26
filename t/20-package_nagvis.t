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

my $sitename  = "testsite";

my $num_tests = 372;
if($ENV{NAGVIS_DEVEL}) {
    $num_tests += 3;
}

my $has_thruk = 1;
if (! -e '/omd/sites/' . $sitename .  '/etc/thruk') {
    $num_tests -= 8;
    $has_thruk = 0;
}

my $has_cmk = 1;
if (! -e '/omd/sites/' . $sitename .  '/etc/check_mk') {
    $num_tests -= 8;
    $has_cmk = 0;
}

plan(tests => $num_tests);

##################################################
# create our test site
my $response;
my $userId;
my $omd_bin   = TestUtils::get_omd_bin();
my $site      = TestUtils::create_test_site($sitename) or TestUtils::bail_out_clean("no further testing without site");
my $auth      = 'OMD Monitoring Site '.$site.':omdadmin:omd';
my $orig_auth = $auth;

# create test host/service
TestUtils::prepare_obj_config('t/data/omd/testconf1', '/omd/sites/'.$site.'/etc/nagios/conf.d', $site);

# Developer test: Install NagVis into local hierarchy
if($ENV{NAGVIS_DEVEL}) {
    TestUtils::test_command({ cmd => "/bin/bash -c 'cd /d1/lm/nagvis ; SITE=testsite bash .f12'" });
}

my $version = site_nagvis_version($site);

##################################################
# Check installation paths
site_thing_exists($site, 'etc/nagvis/maps');
site_thing_exists($site, 'etc/nagvis/geomap');
site_thing_exists($site, 'etc/nagvis/conf.d');
site_thing_exists($site, 'etc/nagvis/conf.d/omd.ini.php');
site_thing_exists($site, 'etc/nagvis/conf.d/urls.ini.php');
site_thing_exists($site, 'etc/nagvis/conf.d/demo.ini.php');
site_thing_exists($site, 'etc/nagvis/nagvis.ini.php');
site_thing_exists($site, 'share/nagvis/htdocs');
site_thing_exists($site, 'share/nagvis/htdocs');
site_thing_exists($site, 'local/share/nagvis/htdocs');

##################################################
# Check NAGVIS_URLS switcher

# Ensure the site is stopped, but don't care about the exit code here!
TestUtils::test_command({ cmd => $omd_bin." stop $site", exit => -1 });

#TestUtils::test_command({ cmd => $omd_bin." config $site set NAGVIS_URLS auto" });
TestUtils::test_command({ cmd => $omd_bin." config $site set DEFAULT_GUI welcome" });
# Now grep conf.d/urls.ini.php for lines matching
# a) hosturl="[htmlcgi]/status.cgi?host=[host_name]"
# b) htmlcgi="/nv/nagios/cgi-bin"
TestUtils::test_command({ cmd  => "/bin/su - $site -c 'cat etc/nagvis/conf.d/urls.ini.php'",
                          like => [ '/hosturl="\[htmlcgi\]\/status.cgi\?host=\[host_name\]"/',
                                    '/htmlcgi="\/'.$site.'\/nagios\/cgi-bin"/' ] });

if (-e '/omd/sites/' . $site .  '/etc/nagios') {
    TestUtils::test_command({ cmd => $omd_bin." config $site set DEFAULT_GUI nagios" });
    TestUtils::test_command({ cmd  => "/bin/su - $site -c 'cat etc/nagvis/conf.d/urls.ini.php'",
                              like => [ '/hosturl="\[htmlcgi\]\/status.cgi\?host=\[host_name\]"/',
                                        '/htmlcgi="\/'.$site.'\/nagios\/cgi-bin"/' ] });
} else {
    # dummy tests to statisfy number of tests (did not know how to decrease number of them)
    TestUtils::test_command({ cmd => "/bin/echo skip nagios url test"});
    TestUtils::test_command({ cmd => "/bin/echo skip nagios url test"});
}

if ($has_thruk) {
    TestUtils::test_command({ cmd => $omd_bin." config $site set DEFAULT_GUI thruk" });
    TestUtils::test_command({ cmd  => "/bin/su - $site -c 'cat etc/nagvis/conf.d/urls.ini.php'",
                              like => [ '/hosturl="\[htmlcgi\]\/status.cgi\?host=\[host_name\]"/',
                                        '/htmlcgi="\/'.$site.'\/thruk\/cgi-bin"/' ] });
}

if ($has_cmk) {
    TestUtils::test_command({ cmd => $omd_bin." config $site set DEFAULT_GUI check_mk" });
    TestUtils::test_command({ cmd  => "/bin/su - $site -c 'cat etc/nagvis/conf.d/urls.ini.php'",
                              like => [ '/hosturl="\[htmlcgi\]\/view\.py\?view_name=host&site=&host=\[host_name\]"/',
                                        '/htmlcgi="\/'.$site.'\/check_mk"/' ] });
}

##################################################
# Prepare the site for testing...

TestUtils::test_command({ cmd => $omd_bin." config $site set DEFAULT_GUI nagvis" });
TestUtils::test_command({ cmd => $omd_bin." start $site" });

##################################################
# Some checks to ensure the basic functionality

my $tests = [
    { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 30 -H localhost -u /$site/nagvis -e 401'",
      like => '/HTTP OK:/' },
    { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 30 -H localhost -a omdadmin:omd -u /$site/nagvis -e 301'",
      like => '/HTTP OK:/' },
    { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 30 -H localhost -a omdadmin:omd -u /$site/nagvis/ -e 301'",
      like => '/HTTP OK:/' },
    { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 30 -H localhost -a omdadmin:omd -u /$site/nagvis/frontend/nagvis-js/index.php -e 200'",
      like => '/HTTP OK:/' },
    { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 30 -H localhost -a omdadmin:omd -u /$site/nagvis/frontend -e 301'",
      like => '/HTTP OK:/' },
    { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 30 -H localhost -a omdadmin:omd -u /$site/nagvis/frontend/ -e 301'",
      like => '/HTTP OK:/' },
    { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 30 -H localhost -a omdadmin:omd -u /$site/nagvis/frontend/wui -e 301'",
      like => '/HTTP OK:/' },
    { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 30 -H localhost -a omdadmin:omd -u /$site/nagvis/frontend/wui/ -e 301'",
      like => '/HTTP OK:/' },
    { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 30 -H localhost -a omdadmin:omd -u /$site/nagvis/frontend/wui/index.php -e 301'",
      like => '/HTTP OK:/' },
    { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 30 -H localhost -a omdadmin:omd -u /$site/nagvis/index.php -e 301'",
      like => '/HTTP OK:/' },
    { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 30 -H localhost -a omdadmin:omd -u /$site/nagvis/config.php -e 301'",
      like => '/HTTP OK:/' },
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
    url({ url  => "/nagvis/frontend/nagvis-js/index.php?mod=Info&lang=en_US",
          like => '/NagVis Support Information<\/title>/' }),
    url({ url  => "/nagvis/frontend/nagvis-js/index.php?mod=Map&act=view&show=demo-germany",
          like => '/, \'demo-germany\'/', 'skip_html_lint' => 1 }),
  
    # Old redirects to maps
    url({ url  => "/nagvis/index.php?map=demo-germany",
          like => '/, \'demo-germany\'/', 'skip_html_lint' => 1 }),
    url({ url  => "/nagvis/config.php?map=demo-germany",
          like => '/, \'demo-germany\'/', 'skip_html_lint' => 1 }),
    url({ url  => "/nagvis/index.php?rotation=demo",
          like => '/, \'demo-germany\'/', 'skip_html_lint' => 1 }),
  
    # Ajax fetched dialogs
    # FIXME: only valid when not using trusted auth:
    #api_url({ url  => '/nagvis/server/core/ajax_handler.php?mod=ChangePassword&act=view',
    #          like => [ '/{"code":"/', '/changePasswordForm/' ]}),
    api_url({ url  => '/nagvis/server/core/ajax_handler.php?mod=UserMgmt&act=view&lang=en_US',
              like => [ '/Create User/', '/"code":"/' ]}),
    api_url({ url  => '/nagvis/server/core/ajax_handler.php?mod=RoleMgmt&act=view&lang=en_US',
              like => [ '/Create Role/', '/"code":"/' ]}),
  
    # Language switch
    url({ url  => "/nagvis/frontend/nagvis-js/index.php?lang=de_DE",
          like => '/Sprache w&auml;hlen/'}),
  
    # Language switch back
    url({ url  => "/nagvis/frontend/nagvis-js/index.php?lang=en_US",
          like => '/Choose Language/'}),
  
    # Documentations
    url({ url  => "/nagvis/docs/de_DE/index.html",
          like => '/NagVis (.*) Dokumentation/'}),
    url({ url  => "/nagvis/docs/en_US/index.html",
          like => '/NagVis (.*) Documentation/'}),
];

# perform tests
for my $url ( @{$urls} ) {
    TestUtils::test_url($url);
}

##################################################
# Environment auth tests

# Create user "omduser" in omd site
# SLES11 does not have a "htpasswd" binary. Use the available htpasswd2 binary in that case.
#my $htpasswd = "htpasswd";
#if(system("which $htpasswd >/dev/null 2>&1") != 0) {
#    $htpasswd = "htpasswd2";
#}
#TestUtils::test_command({ cmd  => "/bin/su - $site -c '$htpasswd -b /omd/sites/$site/etc/htpasswd omduser test 2>/dev/null'"});
TestUtils::test_command({ cmd => "/bin/sh -c \"echo 'omduser:bbTdyOM4g6r9Q' >> /omd/sites/".$site."/etc/htpasswd\""});

# Now try to auth with that user (environment auth)
$auth = 'OMD Monitoring Site '.$site.':omduser:test';
TestUtils::test_url(
    url({ url  => '/nagvis/frontend/nagvis-js/index.php',
          like => '/Logged in: omduser/'})
);
$auth = $orig_auth;

# Fetch user management dialog
$response = TestUtils::test_url(
    api_url({ url  => '/nagvis/server/core/ajax_handler.php?mod=UserMgmt&act=view',
              like => '/Create User/' })
);

# Get the id of the user
$userId = "";
if($response->{'content'} =~ m/<option value=\\\"([0-9]*)\\\">omduser<\\\/option>/g) {
    $userId = $1;
}
ok($userId ne "", 'User-ID of omduser: '.$userId) or diag('Unable to gather the userid!');

# Check roles of the user
TestUtils::test_url(
    api_url_list({ url  => '/nagvis/server/core/ajax_handler.php?mod=UserMgmt&act=getUserRoles&userId='.$userId,
                   like => '/^\[{"roleId":"3","name":"Guests"}\]$/'})
);

##################################################
# User management tests

# 1. Create a user
#    http://127.0.0.1/testsite/nagvis/server/core/ajax_handler.php?mod=UserMgmt&act=doAdd&_t=1322353697000
#    password1  123
#    password2  123
#    username   testuser
#    submit Create User
TestUtils::test_url(
    api_url({ url  => '/nagvis/server/core/ajax_handler.php?mod=UserMgmt&act=doAdd',
              post => { password1 => '123', password2 => '123', username => 'testuser', 'submit' => 'Create User' },
              like => '/^{"message":"The user has been created/' })
);

# 2. Fetch user management dialog
# http://127.0.0.1/testsite/nagvis/server/core/ajax_handler.php?mod=UserMgmt&act=view&_t=1322354360000
$response = TestUtils::test_url(
    api_url({ url  => '/nagvis/server/core/ajax_handler.php?mod=UserMgmt&act=view',
              like => '/Create User/' })
);

# 3. Get the id of the new user
$userId = "";
if($response->{'content'} =~ m/<option value=\\\"([0-9]*)\\\">testuser<\\\/option>/g) {
    $userId = $1;
}
ok($userId ne "", 'User-ID of testuser: '.$userId) or diag('Unable to gather the userid!');

# 4. get all roles of the user
TestUtils::test_url(
    api_url_list({ url  => '/nagvis/server/core/ajax_handler.php?mod=UserMgmt&act=getUserRoles&userId='.$userId,
                   like => '/^\[\]$/'})
);

# 5. add a role to the user
TestUtils::test_url(
    api_url({ url  => '/nagvis/server/core/ajax_handler.php?mod=UserMgmt&act=doEdit',
              post => { submit => "Modify User", userId => $userId, 'rolesSelected[]' => 1},
              like => '/The roles for this user have been updated/'})
);

# 6. verify user roles
TestUtils::test_url(
    api_url_list({ url  => '/nagvis/server/core/ajax_handler.php?mod=UserMgmt&act=getUserRoles&userId='.$userId,
                   like => '/^\[{"roleId":"1","name":"Administrators"}\]$/'})
);

###

# 8. Now try to delete this user again
TestUtils::test_url(
    api_url({ url    => '/nagvis/server/core/ajax_handler.php?mod=UserMgmt&act=doDelete',
              post   => { userId => $userId, submit => 'Delete User' },
              like   => [ '/^{"message":"The user has been deleted/' ]})
);

TestUtils::test_url(
    api_url({ url  => '/nagvis/server/core/ajax_handler.php?mod=UserMgmt&act=view',
              like   => '/Create User/',
              unlike => '/<option value=\\\"'.$userId.'\\\">testuser<\\\/option>/'})
);

##################################################
# Logon dialog tests

# - Change the LogonModule to LogonDialog in nagvis
# - Disable the basic auth for /<site>/nagvis
site_write_file($site, 'etc/nagvis/conf.d/auth.ini.php', "[global]\nlogonmodule=\"LogonDialog\"");
site_write_file($site, 'etc/apache/conf.d/nagvis-auth.conf', "<Location \"/".$site."/nagvis\">\n"
                                                            ."Order allow,deny\n"
                                                            ."Allow from all\n"
                                                            ."Satisfy any\n"
                                                            ."</Location>\n");
TestUtils::test_command({ cmd => $omd_bin." restart $site apache" });
$auth = '';

TestUtils::test_url(
    url({ url  => '/nagvis/frontend/nagvis-js/index.php',
          like => [ '/form name="loginform"/', '/name="_username"/', '/name="_password"/' ]})
);

# perform a random request which sould not be allowed to be requested by non logged in users
TestUtils::test_url(
    url({ url  => '/nagvis/server/core/ajax_handler.php?mod=General&act=getHoverTemplate&name[]=default',
          like => [ '/{"message":"You are not authenticated"/' ]})
);

#diag('Test an invalid login');
TestUtils::test_url(
    url({ url  => '/nagvis/frontend/nagvis-js/index.php',
          post => { _username => 'omdadmin', _password => 'XXX', submit => 'Login' },
          like => [ '/form name="loginform"/', '/name="_username"/',
                    '/name="_password"/', '/Authentication failed/' ]})
);

#diag('Test logging in using the login dialog');
TestUtils::test_url(
    url({ url  => '/nagvis/frontend/nagvis-js/index.php',
          post => { _username => 'omdadmin', _password => 'omd', submit => 'Login' },
          like => [ '/<!-- Start header menu -->/', '/Logged in: omdadmin/' ]})
);

#diag('Test logging in using _GET vars');
TestUtils::test_url(
    url({ url  => '/nagvis/frontend/nagvis-js/index.php?_username=omdadmin&_password=omd',
          like => [ '/<!-- Start header menu -->/', '/Logged in: omdadmin/' ]})
);

#diag('Test logging in at ajax API using _GET vars');
# Use random page to login by GET vars
TestUtils::test_url(
    url({ url  => '/nagvis/server/core/ajax_handler.php?mod=General&act=getHoverTemplate&name[]=default'
                 .'&_username=omdadmin&_password=omd',
          like => [ '/"name":"default","css_file":/' ]})
);

# Disable dialog auth to use the environment auth for further testing
$auth = $orig_auth;
site_remove_file($site, 'etc/apache/conf.d/nagvis-auth.conf');
site_remove_file($site, 'etc/nagvis/conf.d/auth.ini.php');
TestUtils::test_command({ cmd => $omd_bin." restart $site apache" });

##################################################
# AJAX API tests

# /nagvis/server/core/ajax_handler.php?mod=General&act=getHoverTemplate&name[]=default
# [{"name":"default","code":"<...>"}]
TestUtils::test_url(
    api_url_list({ url  => '/nagvis/server/core/ajax_handler.php?mod=General&act=getHoverTemplate&name[]=default',
                   like => [ '/"name":"default","css_file":/' ]})
);

# /nagvis/server/core/ajax_handler.php?mod=General&act=getContextTemplate&name[]=default
# [{"name":"default","code":"<...>"}]
TestUtils::test_url(
    api_url_list({ url  => '/nagvis/server/core/ajax_handler.php?mod=General&act=getContextTemplate&name[]=default',
                   like => [ '/"name":"default","css_file":/' ]})
);

# /nagvis/server/core/ajax_handler.php?mod=Map&act=getMapProperties&show=demo
# {"map_name":"demo","alias":"demo","background_image":"\/nagvis\/userfiles\/images\/maps\/nagvis-demo.png","background_color":"transparent","favicon_image":"\/nagvis\/frontend\/nagvis-js\/images\/internal\/favicon.png","page_title":"demo ([SUMMARY_STATE]) :: NagVis 1.5.7","event_background":"0","event_highlight":"1","event_highlight_interval":"500","event_highlight_duration":"10000","event_log":"0","event_log_level":"info","event_log_height":"100","event_log_hidden":1,"event_scroll":"1","event_sound":"1","in_maintenance":"0"}
TestUtils::test_url(
    api_url({ url  => '/nagvis/server/core/ajax_handler.php?mod=Map&act=getMapProperties&show=demo-germany',
              like => [ '/"map_name":"demo-germany",/' ]})
);

# /nagvis/server/core/ajax_handler.php?mod=Map&act=getMapObjects&show=demo
# FIXME: Add sepecial tests for object states here using the test backend
TestUtils::test_url(
    api_url_list({ url  => '/nagvis/server/core/ajax_handler.php?mod=Map&act=getMapObjects&show=demo-germany',
                   like => [ '/"alias":"Demo: 0 Overview Germany"/' ]})
);

# /nagvis/server/core/ajax_handler.php?mod=Map&act=getObjectStates&show=demo&ty=state&i[]=2&t[]=host&n1[]=host-down-hard&n2[]=
# FIXME: Add sepecial tests for object states here using the test backend
# 1. Match the object state
# 2. Match the member list
TestUtils::test_url(
    api_url_list({ url  => '/nagvis/server/core/ajax_handler.php?mod=Map&act=getObjectStates&show=demo-germany&ty=state&i[]=d99295',
                   like => [ '/{"state":/', '/"members":\[{"/' ]})
);

###############################################################################
# OVERVIEW
###############################################################################
# /nagvis/server/core/ajax_handler.php?mod=Overview&act=getOverviewProperties
# {"cellsperrow":4,"showautomaps":1,"showmaps":1,"showgeomap":0,"showmapthumbs":0,"showrotations":1,"page_title":"NagVis 1.5.7","favicon_image":"\/nagvis\/frontend\/nagvis-js\/images\/internal\/favicon.png","background_color":"#ffffff","lang_mapIndex":"Map Index","lang_automapIndex":"Automap Index","lang_rotationPools":"Rotation Pools","event_log":0,"event_log_level":"info","event_log_height":100,"event_log_hidden":1}
TestUtils::test_url(
    api_url({ url  => '/nagvis/server/core/ajax_handler.php?mod=Overview&act=getOverviewProperties',
              like => [ '/"showmaps":1,"showgeomap":0,"showmapthumbs":0,"showrotations":1/', ]})
);

# /nagvis/server/core/ajax_handler.php?mod=Overview&act=getOverviewRotations
TestUtils::test_url(
    api_url_list({ url  => '/nagvis/server/core/ajax_handler.php?mod=Overview&act=getOverviewRotations',
                   like => [ '/"name":"demo-germany",/', ]})
);

# /nagvis/server/core/ajax_handler.php?mod=General&act=getObjectStates&ty=state&i[]=automap-0&t[]=automap&n1[]=__automap&n2[]=
# http://127.0.0.1/nagvis/server/core/ajax_handler.php?mod=Overview&act=getObjectStates&ty=state&i[]=automap-__automap&_t=1298764833000
TestUtils::test_url(
    api_url_list({ url  => '/nagvis/server/core/ajax_handler.php?mod=Overview&act=getObjectStates&ty=state&i[]=automap-__automap',
                   like => [ '/"state":"/', ]})
);

TestUtils::test_url(
  api_url_list({ url  => '/nagvis/server/core/ajax_handler.php?mod=Overview&act=getObjectStates&ty=state&i[]=automap-notexisting',
                 like => [ '/"state":"ERROR/', '/Map Error: The path /' ]})
);

###############################################################################
# Test user config
###############################################################################
# Language switch
TestUtils::test_url(url({ url  => "/nagvis/frontend/nagvis-js/index.php?lang=de_DE",
                          like => '/Sprache w&auml;hlen/'}));

# Check profile file
site_match_file($site, 'var/nagvis/profiles/omdadmin.profile', '/"language":"de_DE"/');

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
    $url->{'skip_link_check'} = [ 'lang=' ];
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

sub get_maincfg_files {
    my $site = shift;
    my @files = ();

    # Get all nagvis config files
    opendir(my($dh), '/omd/sites/'.$site.'/etc/nagvis/conf.d') or die("Couldn't open dir conf.d dir: $!");
    while(my $file = readdir($dh)) {
        if($file =~ m/.*\.ini\.php/g) {
            push(@files, 'conf.d/' . $file);
        }
    }
    closedir($dh);
    push(@files, 'nagvis.ini.php');
    return @files;
}

sub site_nagvis_maincfg_mtime {
    my $site = shift;
    my $newest = 0;
    my $age;

    for my $file (get_maincfg_files($site)) {
        $age = site_mtime($site, 'etc/nagvis/' . $file);
        $newest = ($age > $newest ? $age : $newest);
    }
    return $newest;
}

sub site_remove_file {
    unlink '/omd/sites/'.shift(@_).'/'.shift(@_);
}

sub site_write_file {
    my $path = '/omd/sites/'.shift(@_).'/'.shift(@_);
    open(FILE, '>'.$path) or fail("Could not open file ".$path.".");
    print FILE shift(@_);
    close(FILE);
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

=head2 site_match_file

    Checks if the specified pattern can be found in the given file.
    The path is given as relative path to the sites base directory.
    This function returns 1 if the pattern could be found or 0 if
    there was no match in the file.

=cut
sub site_match_file {
    my $site    = shift;
    my $fpath   = shift;
    my $pattern = shift;
    my $path    = '/omd/sites/' . $site . '/' . $fpath;

    #diag('Checking file contents of '.$path);

    open FILE, '<'.$path or fail("Could not open file.");
    my $content = do { local $/; <FILE> };
    close(FILE);

    like($content, $pattern, "content like ".$pattern) or diag('Contents: '.$content);
}

=head2 site_thing_exists

    Checks if the specified directory/link/file exists. Fails if
    the thing does not exist.

=cut
sub site_thing_exists {
    my $site    = shift;
    my $fpath   = shift;
    my $path    = '/omd/sites/' . $site . '/' . $fpath;

    #diag('Checking file exists '.$path);
    #TestUtils::test_command({ cmd => "[ -f '.$path.' ]" });
    ok(-e $path, 'Checking file exists '.$path) or diag('File does not exist!');
}

=head2 site_nagvis_version

    Returns version string for the sites NagVis version. It takes the
    local/ path installations into account.

=cut
sub site_nagvis_version {
    my $site = shift;
    my $version = '';
    my $path;
    if(-e '/omd/sites/' . $site .  '/local/share/nagvis/htdocs/server/core/defines/global.php') {
        $path = '/omd/sites/' . $site .  '/local/share/nagvis/htdocs/server/core/defines/global.php';
    } else {
        $path = '/omd/sites/' . $site .  '/share/nagvis/htdocs/server/core/defines/global.php';
    }
    open FILE, $path or die("Could not open file.");
    foreach my $line (<FILE>) {
        if($line =~ m/^define\('CONST_VERSION', '([^']*)'/) {
            $version = $1;
        }
    }
    close(FILE);
    return $version;
}
