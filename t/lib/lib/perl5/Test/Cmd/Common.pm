# Copyright 1999-2001 Steven Knight.  All rights reserved.  This program
# is free software; you can redistribute it and/or modify it under the
# same terms as Perl itself.
#
# This package tests an executable program or script,
# managing one or more temporary working directories,
# keeping track of standard and error output,
# and cleaning up after everything is done.

package Test::Cmd::Common;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK
	    $_exe $_o $_so $_a $_is_win32);
use Exporter ();

$VERSION = '1.05';
@ISA = qw(Test::Cmd Exporter);

@EXPORT_OK = qw($_exe $_o $_a $_so $_is_win32);

use Config;
use Cwd;
use File::Copy ();
use Test::Cmd;


=head1 NAME

Test::Cmd::Common - module for common Test::Cmd error handling

=head1 SYNOPSIS

  use Test::Cmd::Common;

  $test = Test::Cmd::Common->new(string => 'functionality being tested',
  			prog => 'program_under_test',
			);

  $test->run(chdir => 'subdir', fail => '$? != 0',
		flags => '-x', targets => '.',
		stdout => <<_EOF_, stderr => <<_EOF_);
  expected standard output
  _EOF_
  expected error output
  _EOF_

  $test->subdir('subdir', ...);

  $test->read(\$contents, 'file');
  $test->read(\@lines, 'file');

  $test->write('file', <<_EOF_);
  contents of the file
  _EOF_

  $test->file_matches();

  $test->must_exist('file', ['subdir', 'file'], ...);

  $test->must_not_exist('file', ['subdir', 'file'], ...);

  $test->copy('src_file', 'dst_file');

  $test->chmod($mode, 'file', ...);

  $test->sleep;
  $test->sleep($seconds);

  $test->touch('file', ...);

  $test->unlink('file', ...);

=head1 DESCRIPTION

The C<Test::Cmd::Common> module provides a simple, high-level interface
for writing tests of executable commands and scripts, especially
commands and scripts that interact with the file system.  All methods
throw exceptions and exit on failure.  This makes it unnecessary to add
explicit checks for return values, making the test scripts themselves
simpler to write and easier to read.

The C<Test::Cmd::Common> class is a subclass of C<Test::Cmd>.  In
essence, C<Test::Cmd::Common> is a wrapper that treats common
C<Test::Cmd> error conditions as exceptions that terminate the test.
You can use C<Test::Cmd::Common> directly, or subclass it for your
program and add additional (or override) methods to tailor it to your
program's specific needs.  Alternatively, C<Test::Cmd::Common> serves as
a useful example of how to define your own C<Test::Cmd> subclass.

The C<Test::Cmd::Common> module provides the following importable
variables:

=over 4

=item C<$_exe>

The executable file suffix.  This value is normally available
as C<$Config{_exe}> in Perl version 5.005 and later.  The
C<Test::Cmd::Common> module figures it out via other means in earlier
versions.

=item C<$_o>

The object file suffix.  This value is normally available
from C<$Config{_o}> in Perl version 5.005 and later.  The
C<Test::Cmd::Common> module figures it out via other means in earlier
versions.

=item C<$_a>

The library file suffix.  This value is normally available
from as C<$Config{_a}> in Perl version 5.005 and later.  The
C<Test::Cmd::Common> module figures it out via other means in earlier
versions.

=item C<$_so>

The shared library file suffix.  This value is normally available
as C<$Config{_so}> in Perl version 5.005 and later.  The
C<Test::Cmd::Common> module figures it out via other means in earlier
versions.

=item C<$_is_win32>

A Boolean value that reflects whether the current platform is a Win32
system.

=back

=head1 METHODS

=over 4

=cut

BEGIN {
    if ($] <  5.003) {
	eval("require Win32");
	$_is_win32 = ! $@;
    } else {
	$_is_win32 = $^O eq "MSWin32";
    }

    $_exe = $Config{_exe};
    $_exe = $Config{exe_ext} if ! defined $_exe;
    $_exe = $_is_win32 ? '.exe' : '' if ! defined $_exe;
    $_o = $Config{_o};
    $_o = $Config{obj_ext}  if ! defined $_o;
    $_o = $_is_win32 ? '.obj' : '.o' if ! defined $_o;
    $_a = $Config{_a};
    $_a = $Config{lib_ext} if ! defined $_a;
    $_a = $_is_win32 ? '.lib' : '.a';
    $_so = ".$Config{so}";
    $_so = $_is_win32 ? '.dll' : '.so' if ! defined $_so;
}

=item C<new>

Creates a new test environment object.  Any arguments are keyword-value
pairs that are passed through to the construct method for the base
class from which we inherit our methods (that is, the C<Test::Cmd>
class).  In the normal case, this should be the program to be tested and
a description of the functionality being tested:

    $test = Test::Cmd::Common->new(prog => 'my_program',
				   string => 'cool new feature');

By default, methods that match actual versus expected output (the
C<run>, and C<file_matches> methods) use an exact match.  Tests that
require regular expression matches can specify this on initialization of
the test environment:

    $test = Test::Cmd::Common->new(prog => 'my_program',
				   string => 'cool new feature',
				   match_sub => \&Test::Cmd::diff_regex);

or by executing the following after initialization of the test
environment:

    $test->match_sub(\&Test::Cmd::diff_regex);

Creates a temporary working directory for the test environment and
changes directory to it.

Exits NO RESULT if the object can not be created, the temporary working
directory can not be created, or the current directory cannot be changed
to the temporary working directory.

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $test = $class->SUPER::new(@_);
    $class->SUPER::no_result(! $test, undef, 1);
    # We're going to chdir to the temporary working directory.
    # So that things work properly relative to the current directory,
    # turn any relative path names in @INC to absolute paths.
    my $cwd = Cwd::cwd();
    map { $_ = $test->catdir($cwd, $_) if ! $test->file_name_is_absolute($_) }
	@INC;
    my $ret = chdir $test->workdir;
    $test->no_result(! $ret, undef, 1);
    if (! grep {$_ eq 'match_sub'} @_) {
	$test->match_sub(\&Test::Cmd::diff_exact);
    }
    bless($test, $class);
}



sub _fail_match_show {
    my($self, $stream, $expected, $actual, $level) = @_;
    my @diffs;
    $self->fail(! $self->match($actual, $expected, \@diffs)
		=> sub {print STDERR
			"diff expected vs. actual contents of $stream =====\n",
			@diffs},
		$level + 1);
}



=item C<run>

Runs the program under test, checking that the test succeeded.
Arguments are keyword-value pairs that affect the manner in which the
program is executed or the results are evaluated.

    chdir => 'subdir'
    fail => 'failure condition'	# default is '$? != 0'
    flags => 'Cons flags'
    stderr => 'expected error output'
    stdout => 'expected standard output'
    targets => 'targets to build'

The test fails if:

  --  The specified failure condition is met.  The default failure
      condition is '$? != 0', i.e. the program exits unsuccesfully.
      A not-uncommon alternative is:

	  $test->run(fail => '$? == 0');	# expect failure

      when testing how the program handles errors.

  --  Actual standard output does not match expected standard output
      (if any).  The expected standard output is an array of lines
      or a scalar which will be split on newlines.

  --  Actual error output does not match expected error output (if
      any).  The expected error output is an array of lines or a
      scalar which will be split on newlines.

      This method will test for NO error output by default if no
      expected error output is specified (unlike standard output).
      The error output test may be explicitly suppressed by
      specifying undef as the "expected" error output:

	  $test->run(stderr => undef);

By default, this method performs an exact match of actual vs. expected
standard output or error output:

    $test->run(stdout => <<_EOF_, stderr => _EOF_);
    An expected STDOUT line, which must be matched exactly.
    _EOF_
    One or more expected STDERR lines,
    which must be matched exactly.
    _EOF_

Tests that require regular expression matches should be executed using a
test environment that calls the C<match_sub> method as follows:

    $test->match_sub(\&Test::Cmd::diff_regex);

    $test->run(stdout => <<_EOF_, stderr => _EOF_);
    An expected (STDOUT|standard output) line\.
    _EOF_
    One or more expected (STDERR|error output) lines,
    which may contain (regexes|regular expressions)\.
    _EOF_

=cut

sub run {
    my $self = shift;
    my %args = @_;
    my $cmd = $args{'args'};
    if (! $cmd) {
	$cmd = $args{'targets'};
	$cmd = "$args{'flags'} $cmd" if $args{'flags'};
    }
    my $lev = $args{'level'} || 0;
    $self->SUPER::run(@_, args => $cmd);
    my $cond = $args{'fail'} || '$? != 0';
    $self->fail(eval $cond
		=> sub {print STDERR $self->stdout, $self->stderr},
		$lev + 1);
    if (defined $args{'stdout'}) {
	my @stdout = $self->stdout;
	$self->_fail_match_show('STDOUT', $args{'stdout'}, \@stdout, $lev + 1);
    }
    $args{'stderr'} = '' if ! grep($_ eq 'stderr', keys %args);
    if (defined $args{'stderr'}) {
	my @stderr = $self->stderr;
	$self->_fail_match_show('STDERR', $args{'stderr'}, \@stderr, $lev + 1);
    }
}



=item C<subdir>

Creates one or more subdirectories in the temporary working directory.
Exits NO RESULT if the number of subdirectories actually created does
not match the number expected.  For compatibility with its superclass
method, returns the number of subdirectories actually created.

=cut

sub subdir {
    my $self = shift;
    my $expected = @_;
    my $ret = $self->SUPER::subdir(@_);
    $self->no_result($expected != $ret,
		=> sub {print STDERR "could not create subdirectories: $!\n"},
		1);
    return $ret;
}



=item C<read>

Reads the contents of a file, depositing the contents in the destination
referred to by the first argument (a scalar or array reference).  If the
file name is not an absolute path name, it is relative to the temporary
working directory.  Exits NO RESULT if the file could not be read for
any reason.  For compatibility with its superclass method, returns TRUE
on success.

=cut

sub read {
    my $self = shift;
    my $destref = shift;
    my $ret = $self->SUPER::read($destref, @_);
    $self->no_result(! $ret
		=> sub {print STDERR "could not read file contents: $!\n"},
		1);
    return 1;
}



=item C<write>

Writes a file with the specified contents.  If the file name is not an
absolute path name, it is relative to the temporary working directory.
Exits NO RESULT if there were any errors writing the file.
For compatibility with its superclass method, returns TRUE on success.

    $test->write('file', <<_EOF_);
    contents of the file
    _EOF_

=cut

sub write {
    my $self = shift;
    my $file = shift; # the file to write to
    my $ret = $self->SUPER::write($file, @_);
    $self->no_result(! $ret
		=> sub {$file = $self->catfile(@$file) if ref $file;
			print STDERR "could not write $file: $!\n"},
		1);
    return 1;
}



=item C<file_matches>

Matches the contents of the specified file (first argument) against the
expected contents.  The expected contents are an array of lines or a
scalar which will be split on newlines.  By default, each expected line
must match exactly its corresponding line in the file:

    $test->file_matches('file', <<_EOF_);
    Line #1.
    Line #2.
    _EOF_

Tests that require regular expression matches should be executed using a
test environment that calls the C<match_sub> method as follows:

    $test->match_sub(\&Test::Cmd::diff_regex);

    $test->file_matches('file', <<_EOF_);
    The (1st|first) line\.
    The (2nd|second) line\.
    _EOF_

=cut

sub file_matches {
    my($self, $file, $regexes) = @_;
    my @lines;
    my $ret = $self->SUPER::read(\@lines, $file);
    $self->no_result(! $ret
		=> sub {print STDERR "could not read contents of $file: $!\n"},
		1);
    my @diffs;
    $self->fail(! $self->match(\@lines, $regexes, \@diffs)
		=> sub {$file = $self->catfile(@$file) if ref $file;
			print STDERR
			"diff expected vs. actual contents of $file =====\n",
			@diffs},
		1);
}



=item C<must_exist>

Ensures that the specified files must exist.  Files may be specified as
an array reference of directory components, in which case the pathname
will be constructed by concatenating them.  Exits FAILED if any of the
files does not exist.

=cut

sub must_exist {
    my $self = shift;
    map(ref $_ ? $self->catfile(@$_) : $_, @_);
    my @missing = grep(! -e $_, @_);
    $self->fail(0 + @missing => sub {print STDERR "files are missing: @missing\n"}, 1);
}



=item C<must_not_exist>

Ensures that the specified files must not exist.  Files may be specified
as an array reference of directory components, in which case the pathname
will be constructed by concatenating them.  Exits FAILED if any of the
files exists.

=cut

sub must_not_exist {
    my $self = shift;
    map(ref $_ ? $self->catfile(@$_) : $_, @_);
    my @exist = grep(-e $_, @_);
    $self->fail(0 + @exist => sub {print STDERR "unexpected files exist: @exist\n"}, 1);
}



=item C<copy>

Copies a file from the source (first argument) to the destination
(second argument).  Exits NO RESULT if the file could not be copied
for any reason.

=cut

sub copy {
    my($self, $src, $dest) = @_;
    my $ret = File::Copy::copy($src, $dest);
    $self->no_result(! $ret
		=> sub {print STDERR "could not copy $src to $dest: $!\n"},
		1);
}



=item C<chmod>

Changes the permissions of a list of files to the specified mode (first
argument).  Exits NO RESULT if any file could not be changed for any
reason.

=cut

sub chmod {
    my $self = shift;
    my $mode = shift;
    my $expected = @_;
    my $ret = CORE::chmod($mode, @_);
    $self->no_result($expected != $ret,
		=> sub {print STDERR "could not chmod files: $!\n"},
		1);
}



=item C<sleep>

Sleeps at least the specified number of seconds.  If no number is
specified, sleeps at least a minimum number of seconds necessary to
advance file time stamps on the current system.  Sleeping more seconds
is all right.  Exits NO RESULT if the time slept was less than specified.

=cut

sub sleep {
    my($self, $seconds) = @_;
    # On Windows systems, DOS and FAT file systems have only a
    # two-second granularity, so we must sleep two seconds to
    # ensure that file time stamps will be newer.
    $seconds = $_is_win32 ? 2 : 1 if ! defined $seconds;
    my $ret = CORE::sleep($seconds);
    $self->no_result($ret < $seconds,
		=> sub {print STDERR "only slept $ret seconds\n"},
		1);
}



=item C<touch>

Updates the access and modification times of the specified files.
Exits NO RESULT if any file could not be modified for any reason.

=cut

sub touch {
    my $self = shift;
    my $time = shift;
    my $expected = @_;
    my $ret = CORE::utime($time, $time, @_);
    $self->no_result($expected != $ret,
		=> sub {print STDERR "could not touch files: $!\n"},
		1);
}



=item C<unlink>

Removes the specified files.  Exits NO RESULT if any file could not be
removed for any reason.

=cut

sub unlink {
    my $self = shift;
    my @not_removed;
    my $file;
    foreach $file (@_) {
	$file = $self->catfile(@$file) if ref $file;
	if (! CORE::unlink($file)) {
	    push @not_removed, $file;
	}
    }
    $self->no_result(@not_removed != 0,
		=> sub {print STDERR "could not unlink files (@not_removed): $!\n"},
		1);
}



1;
__END__

=back

=head1 ENVIRONMENT

The C<Test::Cmd::Common> module also uses the
C<PRESERVE>,
C<PRESERVE_FAIL>,
C<PRESERVE_NO_RESULT>,
and C<PRESERVE_PASS>
environment variables from the C<Test::Cmd> module.
See the C<Test::Cmd> documentation for details.

=head1 SEE ALSO

perl(1), Test::Cmd(3).

The most involved example of using the C<Test::Cmd::Common> module
to test a real-world application is the C<cons-test> testing suite
for the Cons software construction utility.  The suite sub-classes
C<Test::Cmd::Common> to provide common, application-specific
infrastructure across a large number of end-to-end application tests.
The suite, and other information about Cons, is available at:

	http://www.dsmit.com/cons

=head1 AUTHOR

Steven Knight, knight@baldmt.com

=head1 ACKNOWLEDGEMENTS

Thanks to Johan Holmberg for asking the question that led to the
creation of this package.

The general idea of testing commands in this way, as well as the test
reporting of the C<pass>, C<fail> and C<no_result> methods, come from
the testing framework invented by Peter Miller for his Aegis project
change supervisor.  Aegis is an excellent bit of work which integrates
creation and execution of regression tests into the software development
process.  Information about Aegis is available at:

	http://www.tip.net.au/~millerp/aegis.html

=cut
