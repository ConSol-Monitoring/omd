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

plan( tests => 468 );

my $omd_bin = TestUtils::get_omd_bin();

# print omd version
my $vtest = { cmd => $omd_bin." version", "exit" => undef };
TestUtils::test_command($vtest) or TestUtils::bail_out_clean("no further testing without working omd");
my($omd_v, $python_v) = split(/\,\s+/mx, $vtest->{'stdout'});
diag($omd_v);
ok($python_v, "has python version");
diag($python_v);

# extract omd version
$vtest = { cmd => $omd_bin." version -b", "exit" => undef };
TestUtils::test_command($vtest) or TestUtils::bail_out_clean("no further testing without working omd");

# print apache version
my $atest = { cmd => "/bin/sh -c '".TestUtils::config('APACHE_INIT_NAME')." -V | grep \"Server version\"'", "exit" => undef, errlike => undef };
TestUtils::test_command($atest) or TestUtils::bail_out_clean("no further testing without working omd");
diag("Apache ".$atest->{'stdout'});

# print perl version
use Config;
ok($^V, "has perl version");
diag(sprintf("Perl: %s - Arch: %s", $^V, $Config{'archname'}));

# extract php version
my $ptest = { cmd => "/bin/sh -c 'php -v | head -n 1'", "exit" => undef, errlike => undef };
TestUtils::test_command($ptest) or TestUtils::bail_out_clean("no further testing without working omd");
diag($ptest->{'stdout'});

# there should be no sbin/ folder, all binaries should be in bin/
chomp(my $omd_version = $vtest->{'stdout'});
$omd_version =~ s/^.*\s+(\S+)$/$1/gmx;
TestUtils::test_command({ cmd => "/bin/sh -c 'test -e /omd/versions/$omd_version/sbin && ls -la /omd/versions/$omd_version/sbin'", like => ['/^$/'], exit => 1 });

########################################
# execute some commands
my $site  = 'testsite';
my $site2 = 'testsite2';
my $site3 = 'testsite3';
my $tests = [
  { cmd => $omd_bin." doesnotexit",  errlike => '/no such command/', exit => 1  },
  { cmd => $omd_bin." -V",           like => '/^OMD - Open Monitoring Distribution Version/'  },
  { cmd => $omd_bin." -V -b",        like => '/^\d+\.\d+/'  },
  { cmd => $omd_bin." -b -V",        like => '/^\d+\.\d+/'  },
  { cmd => $omd_bin." -V=".$omd_version." version -b", like => '/^\d+\.\d+/'  },
  { cmd => $omd_bin." help",         like => '/General Options/', exit => 1  },
  { cmd => $omd_bin." -h",           like => '/General Options/', exit => 1  },
  { cmd => $omd_bin." help version", like => ['/Options for.*version.*command/', '/output plain text/'], exit => 1  },
  { cmd => $omd_bin." versions",     like => '/^\d+\.\d+( \(default\))?/'  },
  { cmd => $omd_bin." rm $site",     stdin => "yes\n", 'exit' => undef, errlike => undef },
  { cmd => $omd_bin." rm $site2",    stdin => "yes\n", 'exit' => undef, errlike => undef },
  { cmd => $omd_bin." rm $site2",    stdin => "yes\n", 'exit' => undef, errlike => undef },
  { cmd => $omd_bin." create $site", like => '/Created new site '.$site.'./' },
  { cmd => "/bin/su - $site -c 'omd reset etc/htpasswd'", like => '/^$/' },
  { cmd => "/bin/su - $site -c 'test -h etc/nagios/conf.d'", like => '/^$/' },
  { cmd => "/bin/su - $site -c 'test -d etc/naemon/conf.d'", like => '/^$/' },
  { cmd => $omd_bin." sites",        like => '/^'.$site.'\s+\d+\.\d+( \(default\))?/m' },
  { cmd => $omd_bin." config $site show APACHE_TCP_PORT",  like => '/^5000$/' },
  { cmd => $omd_bin." config $site set APACHE_TCP_ADDR 127.0.0.2",  like => '/^$/' },
  { cmd => $omd_bin." config $site show APACHE_TCP_ADDR",  like => '/^127.0.0.2$/' },
  { cmd => "/bin/su - $site -c 'grep -c 127.0.0.2 etc/apache/proxy-port.conf'", like => '/^3$/' },
  { cmd => $omd_bin." config $site set APACHE_TCP_PORT 5010",  like => '/^$/' },
  { cmd => "/bin/su - $site -c 'grep -c 5010 etc/apache/proxy-port.conf'", like => '/^3$/' },
  { cmd => $omd_bin." config $site set APACHE_TCP_PORT 5000",  like => '/^$/' },
  { cmd => $omd_bin." config $site set APACHE_TCP_ADDR 127.0.0.1",  like => '/^$/' },
  { cmd => "/bin/su - $site -c 'grep -c 5010 etc/apache/proxy-port.conf'", like => '/^0$/', exit => 1 },
  { cmd => "/bin/df -k /omd/sites/$site/tmp/.", like => '/tmpfs/m' },
  { cmd => $omd_bin." check $site", like => '/Running configuration check/', errlike => '/Running pre-flight check on configuration/' },
  { cmd => $omd_bin." start $site",  like => '/Starting naemon/' },
  { cmd => $omd_bin." status $site", like => [
                                                '/apache:\s*running/',
                                                '/rrdcached:\s*running/',
                                                '/npcd:\s*running/',
                                                '/naemon:\s*running/',
                                                '/Overall state:\s*running/',
                                               ]
  },
  { cmd => $omd_bin." stop $site",       like => '/Stopping naemon/' },
  { cmd => $omd_bin." cp $site $site2",  like => '/Copying site '.$site.' to '.$site2.'.../',
                                         errlike => '/Apache port \d+ is in use\. I\'ve choosen \d+ instead\./' },
  { cmd => $omd_bin." config $site2 show APACHE_TCP_PORT",  like => '/^5001$/' },
  { cmd => "/bin/su - $site2 -c 'omd -v diff'", like => ['/^$/'] },
  { cmd => "/usr/bin/find /omd/sites/$site2/ -not -user $site2 -ls",  like => '/^\s*$/' },
  { cmd => "/bin/df -k /omd/sites/$site2/tmp/.", like => '/tmpfs/m' },
  { cmd => $omd_bin." mv $site2 $site3", like => '/Moving site '.$site2.' to '.$site3.'.../' },
  { cmd => $omd_bin." config $site3 show APACHE_TCP_PORT",  like => '/^5001$/' },
  { cmd => "/usr/bin/find /omd/sites/$site3/ -not -user $site3 -ls",  like => '/^\s*$/' },
  { cmd => "/bin/df -k /omd/sites/$site3/tmp/.", like => '/tmpfs/m' },
  { cmd => $omd_bin." rm $site3",        like => '/Restarting Apache...\s*OK/', stdin => "yes\n" },
  { cmd => $omd_bin." rm $site",         like => '/Restarting Apache...\s*OK/', stdin => "yes\n" },
  { cmd => $omd_bin." create -u 7017 -g 7018 $site",
                                         like => '/Created new site '.$site.'./',
                                         errlike => '/^(|.*outside of the .* range.*|.*is greater than SYS_UID_MAX.*)$/',
  },
  { cmd => "/bin/su - $site -c 'omd reset etc/htpasswd'", like => '/^$/' },
  { cmd => "/usr/bin/id -u $site",       like => '/7017/' },
  { cmd => "/usr/bin/id -g $site",       like => '/7018/' },
  { cmd => $omd_bin." cp -u 7019 -g 7020 $site $site2",
                                         like => '/Copying site '.$site.' to '.$site2.'.../',
                                         errlike => '/Apache port \d+ is in use\. I\'ve choosen \d+ instead\./' },
  { cmd => "/usr/bin/id -u $site2",      like => '/7019/' },
  { cmd => "/usr/bin/id -g $site2",      like => '/7020/' },
  { cmd => $omd_bin." mv -u 7021 -g 7022 $site2 $site3", like => '/Moving site '.$site2.' to '.$site3.'.../',
                                         errlike => '/^(|.*outside of the .* range.*|.*is greater than SYS_UID_MAX.*)$/',
  },
  { cmd => "/usr/bin/id -u $site3",      like => '/7021/' },
  { cmd => "/usr/bin/id -g $site3",      like => '/7022/' },
  { cmd => $omd_bin." rm $site",         like => '/Restarting Apache...\s*OK/', stdin => "yes\n" },
  { cmd => $omd_bin." rm $site3",        like => '/Restarting Apache...\s*OK/', stdin => "yes\n" },

  # --reuse
  { cmd => $omd_bin." create $site", like => '/Created new site '.$site.'./' },
  { cmd => "/bin/su - $site -c 'omd reset etc/htpasswd'", like => '/^$/' },
  { cmd => $omd_bin." rm --reuse $site", stdin => "yes\n" },
  { cmd => "/usr/bin/id -u $site",       like => '/\d+/' },
  { cmd => "/usr/bin/id -g $site",       like => '/\d+/' },
  { cmd => $omd_bin." create $site2",    like => '/Created new site '.$site2.'./', errlike => '/ERROR: Failed to read config of site testsite./' },
  { cmd => $omd_bin." mv --reuse $site2 $site", like => '/Moving site '.$site2.' to '.$site.'.../' , errlike => '/ERROR: Failed to read config of site testsite./' },
  { cmd => "/usr/bin/id -u $site2",      like => '/\d+/' },
  { cmd => "/usr/bin/id -g $site2",      like => '/\d+/' },
  { cmd => $omd_bin." cp --reuse $site $site2",  like => '/Copying site '.$site.' to '.$site2.'.../',
                                         errlike => '/Apache port \d+ is in use\. I\'ve choosen \d+ instead\./' },
  { cmd => $omd_bin." cp --reuse $site $site2", errlike => '/must be empty/', exit => 1 },
  { cmd => $omd_bin." rm $site2",        like => '/Restarting Apache...\s*OK/', stdin => "yes\n" },

  # --backup
  { cmd => $omd_bin." backup $site /tmp/omd.backup.tgz", like => '/Unmounting temporary filesystem/' },
  { cmd => $omd_bin." rm $site", like => '/Restarting Apache...\s*OK/', stdin => "yes\n" },

  # --restore
  { cmd => $omd_bin." restore /tmp/omd.backup.tgz", like => '/Restoring site testsite from /' },
  { cmd => "/bin/su - $site -c 'omd -f restore /tmp/omd.backup.tgz'", like => '/Restore completed/' },
  { cmd => "/bin/su - $site -c 'find . -user root -ls'", like => '/^$/' },

  # --reset
  { cmd => "/bin/sh -c \"echo '# test newline in profile' >> /omd/sites/$site/.profile\""},
  { cmd => "/bin/sh -c \"rm -rf /omd/sites/$site/etc/rc.d/80-naemon\""},
  { cmd => "/bin/su - $site -c 'omd diff'", like => ['/Changed content .profile/', '/Deleted etc\/rc\.d/80\-naemon/'], exit => 1 },
  { cmd => "/bin/su - $site -c 'omd -v diff .profile'", like => ['/test newline in profile/'], exit => 1 },
  { cmd => "/bin/su - $site -c 'omd reset .profile etc/rc.d/80-naemon'"  },
  { cmd => "/bin/su - $site -c 'omd reset etc/htpasswd'", like => '/^$/' },
  { cmd => "/bin/su - $site -c 'omd -v diff'", like => ['/^$/'] },
  { cmd => "/bin/sh -c \"rm /omd/sites/$site/etc/thruk/*.cfg\""},
  { cmd => "/bin/sh -c \"rm -rf /omd/sites/$site/etc/naemon\""},
  { cmd => "/bin/su - $site -c 'omd diff'", like => ['/Deleted etc\/thruk/cgi.cfg/', '/Deleted etc\/naemon/'], exit => 1 },
  { cmd => "/bin/su - $site -c 'omd reset etc/'"  },
  { cmd => "/bin/su - $site -c 'omd diff'", like => ['/^$/'] },
  { cmd => "/bin/sh -c \"rm -rf /omd/sites/$site/etc/naemon/conf.d\""},
  { cmd => "/bin/su - $site -c 'omd diff'", like => ['/Deleted etc\/naemon\/conf\.d/'], exit => 1 },
  { cmd => "/bin/su - $site -c 'omd reset etc/naemon/conf.d'"  },
  { cmd => "/bin/su - $site -c 'omd diff'", like => ['/^$/'] },

  # parallel mode
  { cmd => $omd_bin." stop -p", like => ["/Invoking 'stop'/", '/Stopping apache/'] },
  { cmd => $omd_bin." start -p", like => ["/Invoking 'start'/", '/Starting apache/'] },
  { cmd => $omd_bin." reload -p", like => ["/Invoking 'reload'/", "/Reloading apache/"] },
  { cmd => $omd_bin." restart -p", like => ["/Invoking 'restart'/", "/Initializing Crontab\.*OK/"] },
];

# run tests
for my $test (@{$tests}) {
    TestUtils::test_command($test) || TestUtils::bail_out_clean("no further testing without working omd", $test);
}

# bulk config change I
TestUtils::test_command({ cmd => "/bin/sh -c 'echo \"APACHE_MODE=ssl\nWEB_REDIRECT=on\nWEB_ALIAS=sitealias\" | omd config $site change'", like => ['/Stopping apache/', '/Stopping naemon/', '/Starting naemon/'] });
TestUtils::restart_system_apache();

# WEB_REDIRECT
TestUtils::test_command({ cmd => "/omd/sites/$site/lib/monitoring-plugins/check_http    -t 60 -H localhost -u '/' -s 'http://localhost/$site/'", like => '/HTTP OK:/' });
TestUtils::test_command({ cmd => "/omd/sites/$site/lib/monitoring-plugins/check_http -S -t 60 -H localhost -u '/' -s 'https://localhost/$site/'", like => '/HTTP OK:/' });
TestUtils::test_command({ cmd => "/omd/sites/$site/lib/monitoring-plugins/check_http    -t 60 -H localhost -u '/$site' -s 'http://localhost/sitealias'", like => '/HTTP OK:/' });
TestUtils::test_command({ cmd => "/omd/sites/$site/lib/monitoring-plugins/check_http -S -t 60 -H localhost -u '/$site' -s 'https://localhost/sitealias'", like => '/HTTP OK:/' });
TestUtils::test_command({ cmd => "/omd/sites/$site/lib/monitoring-plugins/check_http    -t 60 -H localhost -u '/' -f follow -s 'login.cgi'", like => '/HTTP WARN/', exit => 1 });
TestUtils::test_command({ cmd => "/omd/sites/$site/lib/monitoring-plugins/check_http -S -t 60 -H localhost -u '/' -f follow -s 'login.cgi'", like => '/HTTP WARN/', exit => 1 });

# redirects with custom ports (http mode)
TestUtils::test_command({ cmd => "/bin/sh -c 'echo \"APACHE_MODE=own\nWEB_REDIRECT=off\nWEB_ALIAS=\n\" | omd config $site change'", like => ['/Stopping apache/'] });
TestUtils::restart_system_apache();
TestUtils::test_command({ cmd => "/bin/sh -c 'curl -sk http://localhost/$site/'", like => [qr%\Qhttp://localhost:80/$site/\E%] }) or BAIL_OUT("broken");
TestUtils::test_command({ cmd => "/bin/sh -c 'curl -sk http://localhost/$site/omd/'", like => [qr%\Qhttp://localhost:80/$site/thruk/cgi-bin/login.cgi\E%] }) or BAIL_OUT("broken");
TestUtils::test_command({ cmd => "/bin/sh -c 'curl -sk -H \"X-Forwarded-Proto: http\" -H \"X-Forwarded-Port: 1234\" http://localhost/$site/'", like => [qr%\Qhttp://localhost:1234/$site/omd/\E%] }) or BAIL_OUT("broken");
TestUtils::test_command({ cmd => "/bin/sh -c 'curl -sk -H \"X-Forwarded-Proto: https\" -H \"X-Forwarded-Port: 1234\" http://localhost/$site/'", like => [qr%\Qhttps://localhost:1234/$site/omd/\E%] }) or BAIL_OUT("broken");
TestUtils::test_command({ cmd => "/bin/sh -c 'curl -sk -H \"X-Forwarded-Proto: https\" -H \"X-Forwarded-Port: 1234\" -H \"X-Forwarded-Host: vhost.com\" http://localhost/$site/'", like => [qr%\Qhttps://vhost.com:1234/$site/omd/\E%] }) or BAIL_OUT("broken");

# redirects with custom ports (https mode)
TestUtils::test_command({ cmd => "/bin/sh -c 'echo \"APACHE_MODE=ssl\n\" | omd config $site change'", like => ['/Stopping apache/'] }) or BAIL_OUT("broken");
TestUtils::restart_system_apache();
TestUtils::test_command({ cmd => "/bin/sh -c 'curl -sk http://localhost/$site/'", like => [qr%\Qhttps://localhost/$site/\E%] }) or BAIL_OUT("broken");
TestUtils::test_command({ cmd => "/bin/sh -c 'curl -sk https://localhost/$site/'", like => [qr%\Qhttps://localhost:443/$site/omd/\E%] }) or BAIL_OUT("broken");
TestUtils::test_command({ cmd => "/bin/sh -c 'curl -sk https://localhost/$site/omd/'", like => [qr%\Qhttps://localhost:443/$site/thruk/cgi-bin/login.cgi\E%] }) or BAIL_OUT("broken");
TestUtils::test_command({ cmd => "/bin/sh -c 'curl -sk -H \"X-Forwarded-Proto: http\" -H \"X-Forwarded-Port: 1234\" https://localhost/$site/'", like => [qr%\Qhttp://localhost:1234/$site/omd/\E%] }) or BAIL_OUT("broken");
TestUtils::test_command({ cmd => "/bin/sh -c 'curl -sk -H \"X-Forwarded-Proto: https\" -H \"X-Forwarded-Port: 1234\" https://localhost/$site/'", like => [qr%\Qhttps://localhost:1234/$site/omd/\E%] }) or BAIL_OUT("broken");
TestUtils::test_command({ cmd => "/bin/sh -c 'curl -sk -H \"X-Forwarded-Proto: https\" -H \"X-Forwarded-Port: 1234\" -H \"X-Forwarded-Host: vhost.com\" https://localhost/$site/'", like => [qr%\Qhttps://vhost.com:1234/$site/omd/\E%] }) or BAIL_OUT("broken");

# bulk config change II
TestUtils::test_command({ cmd => "/bin/sh -c 'echo \"APACHE_MODE=none\nAUTOSTART=off\" | omd config $site change'", like => ['/Stopping apache/', '/Stopping naemon/', '/Starting naemon/'] });

# cleanup
TestUtils::test_command({ cmd => $omd_bin." rm $site", like => '/Restarting Apache...\s*OK/', stdin => "yes\n" });
