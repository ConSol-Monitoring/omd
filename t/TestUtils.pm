#!/usr/bin/env perl

package TestUtils;

##################################################
# Test Utils
##################################################

use warnings;
use strict;
use Test::More;
use Data::Dumper;
use LWP::UserAgent;
use File::Temp qw/ :POSIX /;

eval { require Test::Cmd; };
if($@) {
    plan( skip_all => "creating testsite requires Test::Cmd" );
}
elsif($> != 0) {
    plan( skip_all => "creating testsite requires root permission" );
}

##################################################
# HTML::Lint installed?
my $use_html_lint = 0;
eval {
    require HTML::Lint;
    $use_html_lint = 1;
};

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
    my($prg,$arg) = split(/\s+/, $test->{'cmd'}, 2);
    my $t = Test::Cmd->new(prog => $prg, workdir => '') or die($!);
    $t->run(args => $arg, stdin => $test->{'stdin'});
    my $rc = $?>>8;

    # run the command
    isnt($rc, undef, "cmd: ".$test->{'cmd'});

    # exit code?
    $test->{'exit'} = 0 unless exists $test->{'exit'};
    if(defined $test->{'exit'}) {
        ok($rc == $test->{'exit'}, "exit code: ".$rc." == ".$test->{'exit'});
    }

    # matches on stdout?
    if(defined $test->{'like'}) {
        for my $expr (ref $test->{'like'} eq 'ARRAY' ? @{$test->{'like'}} : $test->{'like'} ) {
            like($t->stdout, $expr, "stdout like ".$expr);
        }
    }

    # matches on stderr?
    $test->{'errlike'} = '/^$/' unless exists $test->{'errlike'};
    if(defined $test->{'errlike'}) {
        for my $expr (ref $test->{'errlike'} eq 'ARRAY' ? @{$test->{'errlike'}} : $test->{'errlike'} ) {
            like($t->stderr, $expr, "stderr like ".$expr);
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
    test_command({ cmd => "/usr/bin/omd create $site" });
    return $site;
}


##################################################

=head2 remove_test_site

  removes a test site

=cut
sub remove_test_site {
    my $site = shift;
    test_command({ cmd => "/usr/bin/omd rm $site", stdin => "yes\n" });
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
    our $cookie_jar;
    if(!defined $cookie_jar or !-f $cookie_jar) {
        $cookie_jar = tmpnam();
    }

    my $ua = LWP::UserAgent->new;
    $ua->timeout(10);
    $ua->env_proxy;
    $ua->cookie_jar({ file => $cookie_jar });

    if(defined $test->{'auth'}) {
        $test->{'url'} =~ m/(http|https):\/\/(.*?)(\/|:\d+)/;
        my $netloc = $2;
        my $port   = $3;
        if(defined $port and $port =~ m/^:(\d+)/) { $port = $1; } else { $port = 80; }
        my($realm,$user,$pass) = split(/:/, $test->{'auth'}, 3);
        $ua->credentials($netloc.":".$port, $realm, $user, $pass);
    }

    my $response = $ua->get($test->{'url'});

    # response code?
    $test->{'code'} = 200 unless exists $test->{'code'};
    if(defined $test->{'code'}) {
        ok($response->code == $test->{'code'}, "response code: expected ".$response->code." but got ".$test->{'code'});
    }

    # matches output?
    if(defined $test->{'like'}) {
        for my $expr (ref $test->{'like'} eq 'ARRAY' ? @{$test->{'like'}} : $test->{'like'} ) {
            like($response->decoded_content, $expr, "content like ".$expr);
        }
    }

    # not matching output
    if(defined $test->{'unlike'}) {
        for my $expr (ref $test->{'unlike'} eq 'ARRAY' ? @{$test->{'unlike'}} : $test->{'unlike'} ) {
            unlike($response->decoded_content, $expr, "content unlike ".$expr);
        }
    }
}

1;

__END__
