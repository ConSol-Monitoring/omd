#!/usr/bin/env perl

package TestUtils;

##################################################
# Test Utils
##################################################

use warnings;
use strict;
use Test::More;
use Data::Dumper;

eval { require Test::Cmd; };
if($@) {
    plan( skip_all => "creating testsite requires Test::Cmd" );
}
elsif($> != 0) {
    plan( skip_all => "creating testsite requires root permission" );
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
    if(defined $test->{'exp'}) {
        for my $expr (ref $test->{'exp'} eq 'ARRAY' ? @{$test->{'exp'}} : $test->{'exp'} ) {
            like($t->stdout, $expr, "stdout like ".$expr) or diag("stdout failed: ".$t->stdout());
        }
    }

    # matches on stderr?
    $test->{'errexp'} = '/^$/' unless exists $test->{'errexp'};
    if(defined $test->{'errexp'}) {
        for my $expr (ref $test->{'errexp'} eq 'ARRAY' ? @{$test->{'errexp'}} : $test->{'errexp'} ) {
            like($t->stderr, $expr, "stderr like ".$expr) or diag("stderr failed: ".$t->stderr());
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

1;

__END__
