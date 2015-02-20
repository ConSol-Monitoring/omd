#!/usr/bin/env perl

package TestUtils;

##################################################
# Test Utils
##################################################

use warnings;
use strict;
use Carp;
use Cwd;
use Test::More;
use Data::Dumper;
use LWP::UserAgent;
use HTTP::Cookies::Netscape;
use File::Temp qw/ tempfile /;
use File::Copy qw/ cp /;
use File::Basename;
use Test::Cmd;

if($> != 0) {
    plan( skip_all => "creating testsites requires root permission" );
}
our $omd_symlink_created = 0;

##################################################
# HTML::Lint installed?
my $use_html_lint = 0;
eval {
    require HTML::Lint;
    $use_html_lint = 1;
};

##################################################
# dont test over a proxy
delete $ENV{'HTTP_PROXY'};
delete $ENV{'HTTPS_PROXY'};
delete $ENV{'FTP_PROXY'};
delete $ENV{'http_proxy'};
delete $ENV{'https_proxy'};
delete $ENV{'ftp_proxy'};


##################################################

=head2 get_omd_bin

  returns path to omd binary

=cut

sub get_omd_bin {
    our $omd_bin;
    return $omd_bin if defined $omd_bin;

    $omd_bin = $ENV{'OMD_BIN'} || '/usr/bin/omd';

    # first check /omd
    if( ! -e '/omd' ) {
        if($omd_bin eq '/usr/bin/omd') {
            BAIL_OUT('Broken installation, got /usr/bin/omd but no /omd')
        } elsif($omd_bin eq 'destdir/opt/omd/versions/default/bin/omd') {
            symlink(getcwd()."/destdir/omd", '/omd');
            $omd_symlink_created = 1;
        } else {
            BAIL_OUT('did not find a valid /omd, please make sure it exists')
        }
    }
    else {
        if(-l '/omd') {
            my $target = readlink('/omd');
            if($omd_bin eq '/usr/bin/omd') {
                if($target ne "/opt/omd" && $target ne "opt/omd") {
                    BAIL_OUT('symlink for /omd already exists but is wrong: should be: /opt/omd but got: '.$target);
                }
            }
            elsif($omd_bin eq 'destdir/opt/omd/versions/default/bin/omd') {
                if($target ne getcwd()."/destdir/omd") {
                    BAIL_OUT('symlink for /omd already exists but is wrong: should be: '.getcwd().'/destdir/omd but got: '.$target);
                }
            }
        } else {
            BAIL_OUT('cannot run tests, /omd has to be a symlink to '.getcwd().'/destdir/omd (or /opt/omd for testing packages) in order to run tests for the source version');
        }
    }

    -x $omd_bin or BAIL_OUT($omd_bin." is required for further tests: $!");

    return $omd_bin;
}

##################################################

=head2 test_command

  execute a test command

  needs test hash
  {
    cmd     => command line to execute
    exit    => expected exit code (set to undef to ignore exit code verification)
    like    => (list of) regular expressions which have to match stdout
    errlike => (list of) regular expressions which have to match stderr, default: empty
    sleep   => time to wait after executing the command
  }

=cut
sub test_command {
    my $test = shift;
    my($rc, $stderr) = ( -1, '') ;
    my $return = 1;

    # run the command
    isnt($test->{'cmd'}, undef, "running cmd: ".$test->{'cmd'}) or $return = 0;

    my($prg,$arg) = split(/\s+/, $test->{'cmd'}, 2);
    my $t = Test::Cmd->new(prog => $prg, workdir => '') or die($!);
    alarm(300);
    eval {
        local $SIG{ALRM} = sub { die "timeout on cmd: ".$test->{'cmd'}."\n" };
        $t->run(args => $arg, stdin => $test->{'stdin'});
        $rc = $?>>8;
    };
    if($@) {
        $stderr = $@;
    } else {
        $stderr = $t->stderr;
        $stderr = TestUtils::_clean_stderr($stderr);
    }
    alarm(0);

    # exit code?
    $test->{'exit'} = 0 unless exists $test->{'exit'};
    if(defined $test->{'exit'} and $test->{'exit'} != -1) {
        ok($rc == $test->{'exit'}, "exit code: ".$rc." == ".$test->{'exit'}) or do { _diag_cmd($test, $t); $return = 0 };
    }

    # matches on stdout?
    if(defined $test->{'like'}) {
        for my $expr (ref $test->{'like'} eq 'ARRAY' ? @{$test->{'like'}} : $test->{'like'} ) {
            like($t->stdout, $expr, "stdout like ".$expr) or do { diag("\ncmd: '".$test->{'cmd'}."' failed\n"); $return = 0 };
        }
    }

    # matches on stderr?
    $test->{'errlike'} = '/^\s*$/' unless exists $test->{'errlike'};
    if(defined $test->{'errlike'}) {
        for my $expr (ref $test->{'errlike'} eq 'ARRAY' ? @{$test->{'errlike'}} : $test->{'errlike'} ) {
            like($stderr, $expr, "stderr like ".$expr) or do { diag("\ncmd: '".$test->{'cmd'}."' failed"); $return = 0 };
        }
    }

    # sleep after the command?
    if(defined $test->{'sleep'}) {
        ok(sleep($test->{'sleep'}), "slept $test->{'sleep'} seconds") or do { $return = 0 };
    }

    # set some values
    $test->{'stdout'} = $t->stdout;
    $test->{'stderr'} = $t->stderr;
    $test->{'exit'}   = $rc;

    return $return;
}


##################################################

=head2 file_contains

  verify contents of a file

  needs test hash
  {
    file    => file to check
    like    => (list of) regular expressions which have to match
    unlike  => (list of) regular expressions which must not match stderr
  }

=cut
sub file_contains {
    my $test    = shift;
    my $failed  = 0;
    my $content = "";

    my @like = ();
    if(defined $test->{'like'}) {
        @like   = ref $test->{'like'}   eq 'ARRAY' ? @{$test->{'like'}}   : $test->{'like'};
    }
    my @unlike = ();
    if(defined $test->{'unlike'}) {
        @unlike = ref $test->{'unlike'} eq 'ARRAY' ? @{$test->{'unlike'}} : $test->{'unlike'};
    }

    ok(-r $test->{'file'}, $test->{'file'}." does exist");

    SKIP: {
        skip 'file missing', (scalar @like + scalar @unlike) unless -r $test->{'file'};

        local $/ = undef;
        open my $fh, $test->{'file'} or die "Couldn't open file ".$test->{'file'}.": $!";
        binmode $fh;
        $content = <$fh>;

        # matches?
        if(defined $test->{'like'}) {
            for my $expr (@like) {
                like($content, $expr, "content like ".$expr) or $failed++;
            }
        }

        # don't matches
        if(defined $test->{'unlike'}) {
            for my $expr (@unlike) {
                unlike($content, $expr, "output unlike ".$expr) or $failed++;
            }
        }
    };

    return 1 unless $failed;
    return 0;
}


##################################################

=head2 create_test_site

  creates a test site and returns the name

=cut
sub create_test_site {
    my $site = $_[0] || "testsite";
    if(test_command({ cmd => TestUtils::get_omd_bin()." create $site" })) {
        # disable cookie auth for tests
        my $omd_bin = TestUtils::get_omd_bin();
        print `$omd_bin config $site set THRUK_COOKIE_AUTH off`;
        return $site;
    }
    return;
}


##################################################

=head2 remove_test_site

  removes a test site

=cut
sub remove_test_site {
    my $site = shift;
    # kill all processes, sometimes checks are still running and prevent us from removing the site
    test_command({ cmd => "/usr/bin/pkill -2 -U $site; sleep 1;".TestUtils::get_omd_bin()." rm $site", stdin => "yes\n" });
    return;
}


##################################################

=head2 test_url

  test a url

  needs test hash
  {
    url              => url to request
    auth             => authentication (realm:user:pass)
    code             => expected response code
    like             => (list of) regular expressions which have to match content
    unlike           => (list of) regular expressions which must not match content
    skip_html_lint   => flag to disable the html lint checking
    skip_link_check  => (list of) regular expressions to skip the link checks for
    waitfor          => wait till regex occurs (max 120sec)
  }

=cut
sub test_url {
    my $test = shift;

    my $start = time();
    my $page  = _request($test);

    # wait for something?
    if(defined $test->{'waitfor'}) {
        my $now = time();
        my $waitfor = $test->{'waitfor'};
        my $found   = 0;
        while($now < $start + 120) {
            if($page->{'content'} =~ m/$waitfor/mx) {
                ok(1, "content ".$waitfor." found after ".($now - $start)."seconds");
                $found = 1;
                last;
            }
            sleep(1);
            $now = time();
            $page = _request($test);
        }
        fail("content did not occur within 120 seconds") unless $found;
        return $page;
    }

    # response code?
    $test->{'code'} = 200 unless exists $test->{'code'};
    if(defined $test->{'code'}) {
        is($page->{'code'}, $test->{'code'}, "response code for ".$test->{'url'}." is: ".$test->{'code'}) or _diag_request($test, $page);
    }

    # content type?
    if(defined $test->{'content_type'}) {
        is($page->{'content_type'}, $test->{'content_type'}, 'Content-Type is: '.$test->{'content_type'});
    }

    # matches output?
    if(defined $test->{'like'}) {
        defined $page->{'content'} or _diag_request($test, $page);
        for my $expr (ref $test->{'like'} eq 'ARRAY' ? @{$test->{'like'}} : $test->{'like'} ) {
            like($page->{'content'}, $expr, "content like ".$expr);
        }
    }

    # not matching output
    if(defined $test->{'unlike'}) {
        for my $expr (ref $test->{'unlike'} eq 'ARRAY' ? @{$test->{'unlike'}} : $test->{'unlike'} ) {
            unlike($page->{'content'}, $expr, "content unlike ".$expr)  or _diag_request($test, $page);
        }
    }

    # html valitidy
    SKIP: {
        if($page->{'content_type'} =~ 'text\/html') {
            unless(defined $test->{'skip_html_lint'} && $test->{'skip_html_lint'} == 1) {
                if($use_html_lint == 0) {
                    skip "no HTML::Lint installed", 2;
                }
                if($page->{'content'} =~ /^\[.*\]$/mx || $page->{'content'} =~ /^\{.*\}$/mx) {
                    skip "no lint check for json data", 2;
                }
                if($ENV{LINTSKIPPATTERN} && $test->{'url'} =~ m|/$ENV{LINTSKIPPATTERN}/|mx) {
                    skip "lint check skipped by LINTSKIPPATTERN: ".$ENV{LINTSKIPPATTERN}, 2;
                }
                my $lint = new HTML::Lint;
                isa_ok( $lint, "HTML::Lint" );

                $lint->parse($page->{'content'});
                my @errors = $lint->errors;
                @errors = _diag_lint_errors_and_remove_some_exceptions($lint);
                is( scalar @errors, 0, "No errors found in HTML (".$test->{'url'}.")" );
                $lint->clear_errors();
            }
        }
    }

    # check for missing images / css or js
    if($page->{'content_type'} =~ 'text\/html'
       and (!defined $test->{'skip_html_links'} or $test->{'skip_html_links'} == 0)
      ) {
        my $content = $page->{'content'};
        $content =~ s/<\!\-\-.*?\-\->//gsmx;
        my @matches = $content =~ m/(src|href)=['|"](.+?)['|"]/gi;
        my $links_to_check;
        my $x=0;
        for my $match (@matches) {
            $x++;
            next if $x%2==1;
            next if $match =~ m/^http/;
            next if $match =~ m/^mailto:/;
            next if $match =~ m/^#/;
            next if $match =~ m/^javascript:/;
            next if $match =~ m/internal&srv=runtime/;
            if(defined $test->{'skip_link_check'}) {
                my $skip = 0;
                for my $expr (ref $test->{'skip_link_check'} eq 'ARRAY' ? @{$test->{'skip_link_check'}} : $test->{'skip_link_check'} ) {
                    if($skip == 0 and $match =~ m/$expr/) {
                        $skip = 1;
                    }
                }
                next if $skip == 1;
            }
            $links_to_check->{$match} = 1;
        }
        my $errors = 0;
        for my $test_url (keys %{$links_to_check}) {
            $test_url = _get_url($test->{'url'}, $test_url);
            our $already_checked;
            $already_checked = {} unless defined $already_checked;
            next if defined $already_checked->{$test_url};
            #diag("checking link: ".$test_url);
            my $req = _request({url => $test_url, auth => $test->{'auth'}});
            if($req->{'response'}->is_redirect) {
                my $redirects = 0;
                while(my $location = $req->{'response'}->{'_headers'}->{'location'}) {
                    if($location !~ m/^(http|\/)/gmx) { $location = _relative_url($location, $req->{'response'}->base()->as_string()); }
                    $req= _request($location);
                    $redirects++;
                    last if $redirects > 10;
                }
            }
            if($req->{'code'} == 200) {
                $already_checked->{$test_url} = 1;
            } else {
                $errors++;
                diag("got status ".$req->{'code'}." for url: '$test_url'");
                diag(Dumper($req));
                my $tmp_test = { 'url' => $test_url };
                _diag_request($tmp_test, $req);
                TestUtils::bail_out_clean("error in url '$test_url' linked from '".$test->{'url'}."'");
            }
        }
        is( $errors, 0, 'All stylesheets, images and javascript exist' );
    }
    return $page;
}

##################################################

=head2 config

  return config value

=cut
sub config {
    my $key = shift;
    our $config;
    return $config->{$key} if defined $config;

    my $conf_file = "/omd/versions/default/share/omd/distro.info";
    $config = read_config($conf_file);

    return $config->{$key};
}


##################################################

=head2 read_config

  return config from file

=cut
sub read_config {
    my $conf_file = shift;

    my $config = {};
    open(my $fh, '<', $conf_file) or carp("cannot open $conf_file: $!");
    while(<$fh>) {
        my $line = $_;
        chomp($line);
        next if $line =~ m/^\s*(#|$)/;
        $line =~ s/\s*#.*$//;
        my $append = 0;
        my($key,$value) = split/\s+\+=\s*/,$line,2;
        if(defined $value) {
            $append = 1;
        } else {
            ($key,$value) = split/\s+=\s*/,$line,2;
        }
        $key   =~ s/^\s+//;
        $value =~ s/\s+$// if defined $value;
        if($append) {
            $config->{$key} .= " ".$value;
        } else {
            $config->{$key} = $value;
        }
    }
    close($fh);
    return $config;
}



##################################################

=head2 config

  return config value

=cut
sub wait_for_file {
    my $file    = shift;
    my $timeout = shift || 120;

    my $testfile = glob($file);
    $file = $testfile if defined $testfile;

    my $x = 0;
    if(-e $file) {
        pass("file: $file does already exist");
        return 1;
    }
    while($x < $timeout) {
        if(-e $file) {
            pass("file: $file appeared after $x seconds");
            return 1;
        }
        $x++;
        sleep(1);
    }
    fail("file: $file did not appear within $x seconds");
    return 0;
}


##################################################

=head2 wait_for_content

  waits for web page content until timeout

  needs test hash
  {
    url            => url to request
    auth           => authentication (realm:user:pass)
    code           => expected response code
    like           => (list of) regular expressions which have to match content
  }

=cut
sub wait_for_content {
    my $test    = shift;
    my $timeout = shift || 120;

    my $req;
    my $x = 0;
    while ($x < $timeout) {
        $req = _request($test);
        if($req->{'code'} == 200) {
            #diag("code:$req->{code} url:$test->{url} auth:$test->{auth}");
            my $errors=0;
            for my $pattern (@{$test->{'like'}}) {
                if ($req->{'content'}!~/$pattern/) {
                    #diag("errors:$errors pattern:$pattern");
                    $errors++;
                }
            }
            if ($errors == 0) {
                pass(sprintf "content: [ %s ] appeared after $x seconds", join(',',@{$test->{'like'}}));
                return 1;
            }
        } else {
            diag("Error searching for web content:\ncode:$req->{code}\nurl:$test->{url}\nauth:$test->{auth}\ncontent:$req->{content}");
        }
        $x++;
        sleep(1);
    }
    fail(sprintf "content: [ %s ] did not appear within $x seconds", join(',',@{$test->{'like'}}));
    return 0;
}


##################################################

=head2 prepare_obj_config

  prepare test object config

=cut
sub prepare_obj_config {
    my $src  = shift;
    my $dst  = shift;
    my $site = shift;

    my $files = join(" ", (ref $src eq 'ARRAY' ? @{$src} : $src));
    for my $file (`find $files -type f`) {
        chomp($file);
        my $dstfile = $dst;
        if(-d $dst) { $dstfile = $dst.'/'.basename($file); }
        cp($file, $dstfile) or die("copy $file $dstfile failed: $!");
        test_command({ cmd => "/usr/bin/env sed -i $dstfile -e 's/###SITE###/".$site."/' -e 's|###ROOT###|/omd/sites/".$site."|'" }) if defined $site;
    }

    return;
}


##################################################

=head2 bail_out_clean

  bail out from testing but some minor cleanup before

=cut
sub bail_out_clean {
    my $msg = shift;

    carp("cleaning up before bailout");

    my $omd_bin = get_omd_bin();
    for my $site (qw/testsite testsite2 testsite3/) {
        test_command({ cmd => $omd_bin." rm $site", stdin => "yes\n", 'exit' => undef, errlike => undef });
    }

    BAIL_OUT($msg);
    return;
}

##################################################

=head2 _diag_lint_errors_and_remove_some_exceptions

  removes some lint errors we want to ignore

=cut
sub _diag_lint_errors_and_remove_some_exceptions {
    my $lint = shift;
    my @return;
    LINT_ERROR: for my $error ( $lint->errors ) {
        my $err_str = $error->as_string;
        for my $exclude_pattern (
            "<IMG SRC=[^>]*>\ tag\ has\ no\ HEIGHT\ and\ WIDTH\ attributes",
            "<IMG SRC=[^>]*>\ does\ not\ have\ ALT\ text\ defined",
            "<input>\ is\ not\ a\ container\ \-\-\ <\/input>\ is\ not\ allowed",
            "Unknown attribute \"start\" for tag <div>",
            "Unknown attribute \"end\" for tag <div>",
            "for tag <meta>",
            "Unknown\ attribute\ \"placeholder\"\ for\ tag\ <input>",
            "Unknown\ attribute\ \"autocomplete\"\ for\ tag\ <form>",
            "Unknown\ attribute\ \"autocomplete\"\ for\ tag\ <input>",
        ) {
            next LINT_ERROR if($err_str =~ m/$exclude_pattern/i);
        }
        diag($error->as_string."\n");
        push @return, $error;
    }
    return @return;
}


##################################################

=head2 _request

  returns a page

  expects a hash
  {
    url     => url to request
    auth    => authentication (realm:user:pass)
  }

=cut
sub _request {
    my $data = shift;

    my $return = {};
    our($fh, $cookie_jar, $cookie_file);

    if(!defined $cookie_jar) {
        ($fh, $cookie_file) = tempfile();
        unlink ($cookie_file);
        $cookie_jar = HTTP::Cookies::Netscape->new(
                                       file     => $cookie_file,
                                       autosave => 1,
                                       );
    }

    my $ua = LWP::UserAgent->new(
        keep_alive   => 1,
        max_redirect => 10,
        timeout      => 30,
        requests_redirectable => ['GET', 'POST'],
    );
    $ua->timeout(30);
    $ua->env_proxy;
    $ua->cookie_jar($cookie_jar);

    if(defined $data->{'auth'}) {
        $data->{'url'} =~ m/(http|https):\/\/(.*?)(\/|:\d+)/;
        my $netloc = $2;
        my $port   = $3;
        if(defined $port and $port =~ m/^:(\d+)/) { $port = $1; } else { $port = 80; }
        my($realm,$user,$pass) = split(/:/, $data->{'auth'}, 3);
        $ua->credentials($netloc.":".$port, $realm, $user, $pass);
    }

    my $response;
    if(defined $data->{'post'}) {
        $response = $ua->post($data->{'url'}, $data->{'post'});
    } else {
        $response = $ua->get($data->{'url'});
    }

    $return->{'response'}     = $response;
    $return->{'code'}         = $response->code;
    $return->{'content'}      = $response->decoded_content || $response->content;
    $return->{'content_type'} = $response->header('Content-Type');

    return($return);
}


##################################################

=head2 _get_url

  returns a absolute url

  expects
  $VAR1 = origin url
  $VAR2 = target link

=cut
sub _get_url {
    my $url  = shift;
    my $link = shift;
    my $newurl;

    # split original url in host, path and file
    if($url =~ m/^(http|https):\/\/([^\/]*)(|\/|:\d+)(.*?)$/) {
        my $host     = $1."://".$2.$3;
        $host        =~ s/\/$//;      # remove last /
        my $fullpath = $4 || '';
        $fullpath    =~ s/\?.*$//;
        $fullpath    =~ s/^\///;
        my($path,$file) = ('', '');
        if($fullpath =~ m/^(.+)\/(.*)$/) {
            $path = $1;
            $file = $2;
        }
        else {
            $file = $fullpath;
        }
        $path =~ s/^\///; # remove first /

        if($link =~ m/^(http|https):\/\//) {
            return $link;
        }
        elsif($link =~ m/^\//) { # absolute link
            return $host.$link;
        }
        elsif($path eq '') {
            return $host."/".$link;
        } else {
            return $host."/".$path."/".$link;
        }
    }
    else {
        TestUtils::bail_out_clean("unknown url scheme in _get_url: '".$url."'");
    }

    return $newurl;
}


##################################################

=head2 _clean_stderr

  remove some know errors from stderr

=cut
sub _clean_stderr {
    my $text = shift || '';
    $text =~ s/[\w\-]+: Could not reliably determine the server's fully qualified domain name, using .*? for ServerName//g;
    $text =~ s/\[warn\] module \w+ is already loaded, skipping//g;
    $text =~ s/Syntax OK//g;
    $text =~ s/no crontab for \w+//g;
    return $text;
}

##################################################

=head2 _diag_cmd

  print diagnostic output for failed commands

=cut
sub _diag_cmd {
    my $test = shift;
    my $cmd  = shift;
    my $stdout = $cmd->stdout || '';
    my $stderr = $cmd->stderr || '';
    diag("\ncmd: '".$test->{'cmd'}."' failed\n");
    diag("stdout: ".$stdout."\n");
    diag("stderr: ".$stderr."\n");

    # check logfiles on apache errors
    if(   $stdout =~ m/Starting dedicated Apache for site (\w+)[\.\ ]*ERROR/
       or $stdout =~ m/500 Internal Server Error/) {
        my $site = $1;
        _tail("apache logs:", "/omd/sites/$site/var/log/apache/error_log") if defined $site;
        _tail_apache_logs();
        _tail("nagios livestatus nagios logs:", "/omd/sites/$site/var/nagios/livestatus.log") if defined $site;
        _tail("naemon livestatus logs:", "/omd/sites/$site/var/naemon/livestatus.log") if defined $site;
    }
    if( $stderr =~ m/User '(\w+)' still logged in or running processes/ ) {
        my $site = $1;
        diag("ps: ".`ps -fu $site`) if $site;
    }
    return;
}

##################################################

=head2 _diag_request

  print diagnostic output for failed requests

=cut
sub _diag_request {
    my $test  = shift;
    my $page  = shift;

    diag(Dumper($page->{'response'}));

    $test->{'url'} =~ m/localhost\/(\w+)\//;
    my $site = $1;
    return unless defined $site;

    # check logfiles on apache errors
    _tail("apache logs:", "/omd/sites/$site/var/log/apache/error_log");
    _tail_apache_logs();
    _tail("thruk logs:", "/omd/sites/$site/var/log/thruk.log") if $test->{'url'} =~ m/\/thruk\//;

    return;
}

##################################################

=head2 _tail

  print tail of fail

=cut
sub _tail {
    my $name = shift;
    my $file = shift;
    return unless defined $file;
    diag($name);
    if(-f $file) {
        diag(`tail -n100 $file`);
    } else {
        diag("cannot read $file: $!");
    }
    return;
}


##################################################

=head2 _tail_apache_logs

  print tail of all apache logs

=cut
sub _tail_apache_logs {
    _tail("global apache logs:", glob('/var/log/apache*/error*log'));
    _tail("global apache logs:", glob('/var/log/httpd*/error*log'));
    return;
}

##################################################

=head2 restart_system_apache

  restart system apache

=cut
sub restart_system_apache {
    my $name  = TestUtils::config('APACHE_INIT_NAME');
    my $init  = TestUtils::config('INIT_CMD');
    my $cmd   = $init;
    $cmd      =~ s/\Q%(name)s\E/$name/mx;
    my $stop  = $cmd;
    $stop     =~ s/\Q%(action)s\E/stop/mx;
    my $start = $cmd;
    $start    =~ s/\Q%(action)s\E/start/mx;
    $cmd      = $stop.'; sleep 3; '.$start;
    TestUtils::test_command({ cmd => $cmd });
}

##################################################

END {
    our($cookie_file);
    unlink($cookie_file) if $cookie_file;
    if(defined $omd_symlink_created and $omd_symlink_created == 1) {
        unlink('/omd');
    }
};

1;

__END__
