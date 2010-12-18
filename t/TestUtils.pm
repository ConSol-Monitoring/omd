#!/usr/bin/env perl

package TestUtils;

##################################################
# Test Utils
##################################################

use warnings;
use strict;
use Cwd;
use Test::More;
use Data::Dumper;
use LWP::UserAgent;
use File::Temp qw/ :POSIX /;
use Test::Cmd;
use HTML::Lint;

if($> != 0) {
    plan( skip_all => "creating testsites requires root permission" );
}
our $omd_symlink_created = 0;

##################################################

=head2 get_omd_bin

  returns path to omd binary

=cut

sub get_omd_bin {
    our $omd_bin;
    return $omd_bin if defined $omd_bin;

    $omd_bin = $ENV{'OMD_BIN'} || 'destdir/opt/omd/versions/default/bin/omd';

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
        if(-s '/omd') {
            my $target = readlink('/omd');
            if($omd_bin eq '/usr/bin/omd') {
                if($target ne "/opt/omd") {
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

=head2 read_distro_config

  read the distro config

=cut

sub read_distro_config {
    #/omd/versions/default/share/omd/distro.info
}

##################################################

=head2 test_command

  execute a test command

  needs test hash
  {
    cmd     => command line to execute
    exit    => expected exit code
    like    => (list of) regular expressions which have to match stdout
    errlike => (list of) regular expressions which have to match stderr, default: empty
    sleep   => time to wait after executing the command
  }

=cut
sub test_command {
    my $test = shift;
    my( $rc, $stderr);
    my($prg,$arg) = split(/\s+/, $test->{'cmd'}, 2);
    my $t = Test::Cmd->new(prog => $prg, workdir => '') or die($!);
    alarm(120);
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

    # run the command
    isnt($rc, undef, "cmd: ".$test->{'cmd'});

    # exit code?
    $test->{'exit'} = 0 unless exists $test->{'exit'};
    if(defined $test->{'exit'}) {
        ok($rc == $test->{'exit'}, "exit code: ".$rc." == ".$test->{'exit'}) || diag("\ncmd: '".$test->{'cmd'}."' failed\n");
    }

    # matches on stdout?
    if(defined $test->{'like'}) {
        for my $expr (ref $test->{'like'} eq 'ARRAY' ? @{$test->{'like'}} : $test->{'like'} ) {
            like($t->stdout, $expr, "stdout like ".$expr) || diag("\ncmd: '".$test->{'cmd'}."' failed\n");
        }
    }

    # matches on stderr?
    $test->{'errlike'} = '/^$/' unless exists $test->{'errlike'};
    if(defined $test->{'errlike'}) {
        for my $expr (ref $test->{'errlike'} eq 'ARRAY' ? @{$test->{'errlike'}} : $test->{'errlike'} ) {
            like($stderr, $expr, "stderr like ".$expr) || diag("\ncmd: '".$test->{'cmd'}."' failed");
        }
    }

    # sleep after the command?
    if(defined $test->{'sleep'}) {
        ok(sleep($test->{'sleep'}), "slept $test->{'sleep'} seconds");
    }
}

##################################################

=head2 create_test_site

  creates a test site and returns the name

=cut
sub create_test_site {
    my $site = "testsite"; # TODO: make uniq name
    test_command({ cmd => TestUtils::get_omd_bin()." create $site" });
    return $site;
}


##################################################

=head2 remove_test_site

  removes a test site

=cut
sub remove_test_site {
    my $site = shift;
    test_command({ cmd => TestUtils::get_omd_bin()." rm $site", stdin => "yes\n" });
    return;
}


##################################################

=head2 test_url

  test a url

  needs test hash
  {
    url     => url to request
    auth    => authentication (realm:user:pass)
    code    => expected response code
    like    => (list of) regular expressions which have to match content
    unlike  => (list of) regular expressions which must not match content
  }

=cut
sub test_url {
    my $test = shift;

    my $page = _request($test);

    # response code?
    $test->{'code'} = 200 unless exists $test->{'code'};
    if(defined $test->{'code'}) {
        is($page->{'code'}, $test->{'code'}, "response code for ".$test->{'url'}." is: ".$test->{'code'});
    }

    # content type?
    if(defined $test->{'content_type'}) {
        is($page->{'content_type'}, $test->{'content_type'}, 'Content-Type is: '.$test->{'content_type'});
    }

    # matches output?
    if(defined $test->{'like'}) {
        for my $expr (ref $test->{'like'} eq 'ARRAY' ? @{$test->{'like'}} : $test->{'like'} ) {
            like($page->{'content'}, $expr, "content like ".$expr);
        }
    }

    # not matching output
    if(defined $test->{'unlike'}) {
        for my $expr (ref $test->{'unlike'} eq 'ARRAY' ? @{$test->{'unlike'}} : $test->{'unlike'} ) {
            unlike($page->{'content'}, $expr, "content unlike ".$expr);
        }
    }

    # html valitidy
    SKIP: {
        if($page->{'content_type'} =~ 'text\/html') {
            my $lint = new HTML::Lint;
            isa_ok( $lint, "HTML::Lint" );

            $lint->parse($page->{'content'});
            my @errors = $lint->errors;
            @errors = _diag_lint_errors_and_remove_some_exceptions($lint);
            is( scalar @errors, 0, "No errors found in HTML" );
            $lint->clear_errors();
        }
    }

    # check for missing images / css or js
    if($page->{'content_type'} =~ 'text\/html') {
        my @matches = $page->{'content'} =~ m/(src|href)=['|"](.+?)['|"]/gi;
        my $links_to_check;
        my $x=0;
        for my $match (@matches) {
            $x++;
            next if $x%2==1;
            next if $match =~ m/^http/;
            next if $match =~ m/^mailto:/;
            next if $match =~ m/^#/;
            next if $match =~ m/^javascript:/;
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
            if($req->{'code'} == 200) {
                $already_checked->{$test_url} = 1;
            } else {
                $errors++;
                diag("got status ".$req->{'code'}." for url: '$test_url'");
            }
        }
        is( $errors, 0, 'All stylesheets, images and javascript exist' );
    }
    return $page;
}


##################################################

=head2 _diag_lint_errors_and_remove_some_exceptions

  removes some lint errors we want to ignore

=cut
sub _diag_lint_errors_and_remove_some_exceptions {
    my $lint = shift;
    my @return;
    for my $error ( $lint->errors ) {
        my $err_str = $error->as_string;
        if($err_str =~ m/<IMG SRC=".*?\/thruk\/.*?">\ tag\ has\ no\ HEIGHT\ and\ WIDTH\ attributes\./) {
            next;
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
    our $cookie_jar;

    if(!defined $cookie_jar or !-f $cookie_jar) {
        $cookie_jar = tmpnam();
    }

    my $ua = LWP::UserAgent->new;
    $ua->timeout(10);
    $ua->env_proxy;
    $ua->cookie_jar({ file => $cookie_jar });

    if(defined $data->{'auth'}) {
        $data->{'url'} =~ m/(http|https):\/\/(.*?)(\/|:\d+)/;
        my $netloc = $2;
        my $port   = $3;
        if(defined $port and $port =~ m/^:(\d+)/) { $port = $1; } else { $port = 80; }
        my($realm,$user,$pass) = split(/:/, $data->{'auth'}, 3);
        $ua->credentials($netloc.":".$port, $realm, $user, $pass);
    }

    my $response = $ua->get($data->{'url'});

    $return->{'code'}         = $response->code;
    $return->{'content'}      = $response->decoded_content;
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
        BAIL_OUT("unknown url scheme in _get_url: '".$url."'");
    }

    return $newurl;
}


##################################################

=head2 _clean_stderr

  remove some know errors from stderr

=cut
sub _clean_stderr {
    my $text = shift || '';
    $text =~ s/httpd: Could not reliably determine the server's fully qualified domain name, using 127.0.0.1 for ServerName//;
    return $text;
}

END {
    if(defined $omd_symlink_created and $omd_symlink_created == 1) {
        unlink('/omd');
    }
};

1;

__END__
