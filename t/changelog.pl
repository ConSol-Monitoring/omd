#!/usr/bin/env perl

use warnings;
use strict;
use Getopt::Long;

################################################################################
my @categories = qw/thruk naemon gearman grafana prometheus/;
my $renames = {
    'gearmand'              => { cat => "gearman" },
    'promlens'              => { cat => "prometheus" },
    'lmd'                   => { cat => "thruk" },
    'mod-gearman'           => { cat => "gearman" },
    'mod-gearman-worker'    => { cat => "gearman" },
    'mod-gearman-worker-go' => { cat => "gearman" },
};

################################################################################
my($opt_help, $opt_tag, $opt_verbose, $opt_write);
main();
exit(0);

################################################################################
sub main {
    GetOptions ("t|tag=s"   => \$opt_tag,
                "v|verbose" => \$opt_verbose,
                "w|write"   => \$opt_write,
                "h|help   " => \$opt_help)
    or die("Error in command line arguments\n");

    if($opt_write && $opt_tag) {
        die("write can only be used for next (without --tag)");
    }

    # get last git tag
    chomp(my $cur_tag  = `git describe --tag --exact-match 2>/dev/null`);
    my $tag_name = $opt_tag ? "'$opt_tag'^" : "";
    chomp(my $last_tag = `git describe --tag --abbrev=0 --always $tag_name 2>/dev/null`);

    my $cur  = $opt_tag ? $opt_tag : "HEAD";
    my $next = $opt_tag ? $opt_tag : "next";
    _log("generating changes for %s release. (%s .. %s)", $next, $last_tag, $cur) if $opt_verbose;

    my $changes = _get_changes($cur, $last_tag);
    my $txt = _format_changes($cur, $changes);
    print $txt;
    if($opt_write) {
        open(my $changelog, '<', 'Changelog') or die("cannot read Changelog: $!");
        my @old = <$changelog>;
        close($changelog);
        my $head = shift @old;
        shift @old while($old[0] =~ m/^\s*$/mx); # trim empty lines
        if($old[0] =~ m/^next:/mx) {
            shift @old;
            shift @old while($old[0] !~ m/^\s*$/mx); # trim until empty line
            shift @old while($old[0] =~ m/^\s*$/mx); # trim exceeding empty lines
        }

        open($changelog, '>', 'Changelog') or die("cannot write Changelog: $!");
        printf($changelog $head);
        printf($changelog "\n");
        printf($changelog $txt);
        printf($changelog "\n");
        printf($changelog join("", @old));
        close($changelog);
    }
}

################################################################################
sub _format_changes {
    my($cur, $changes) = @_;

	my $txt = "";
    $txt .= sprintf("%s:\n", $cur eq 'HEAD' ? 'next' : $cur);
    for my $cat (@categories) {
        next unless $changes->{$cat};
        $txt .= _format_changes_cat($changes, $cat);
    }
    for my $cat (sort keys %{$changes}) {
        next if $cat ne '';
        $txt .= _format_changes_cat($changes, $cat);
    }
    return($txt);
}

################################################################################
sub _format_changes_cat {
    my($changes, $cat) = @_;
    my $txt = "";
    my $indent = 10;
    if($cat ne '') {
        $txt .= sprintf("%s- %s:\n", (" " x $indent), $cat);
        $indent = 12;
    }
    for my $prj (sort keys %{$changes->{$cat}}) {
        my $version = $changes->{$cat}->{$prj};
        my $name = $prj ? $prj." " : "";
        $txt .= sprintf("%s- %supdate to %s\n", (" " x $indent), $name, $version);
    }
    return($txt);
}

################################################################################
sub _get_changes {
    my($cur, $last_tag) = @_;
    my $changes = {};
    if($cur eq 'HEAD') {
        $cur = "";
    } else {
        $cur = "..".$cur;
    }
    my @files = glob("packages/*/Makefile");
    for my $f (@files) {
        _log("checking version from %s", $f) if $opt_verbose;
        chomp(my $diff  = `git diff $last_tag$cur -- $f 2>/dev/null`);
        if(!$diff) {
            _log(" -> no changes at all") if $opt_verbose;
            next;
        }
        my $version;
        if($diff =~ m/^\+VERSION.*?=\s*(.*)$/mx) {
            $version = $1;
        }
        if($diff =~ m/^\+GIT_TAG.*?=\s*(.*)$/mx) {
            $version = $1;
        }
        if(!$version) {
            _log(" -> version did not change but found other changes") if $opt_verbose;
            next;
        }
        _log(" -> version changed to %s", $version) if $opt_verbose;

        $version =~ s/^v//gmx;
        my $prj = $f;
        $prj =~ s/^.*packages\/([^\/]+)\/.*/$1/gmx;
        next if $prj =~ m/^go\-/gmx;
        my $cat = _get_category($prj);
        $prj =~ s/^$cat[\-_]+//gmx;
        if($prj eq $cat) { $prj = ""; }
        $changes->{$cat}->{$prj} = $version;
    }
    return($changes);
}

################################################################################
sub _get_category {
    my($prj) = @_;
    if($renames->{$prj}->{'cat'}) {
        return($renames->{$prj}->{'cat'});
    }
    for my $cat (@categories) {
        if($prj eq $cat || $prj =~ m/^$cat[\-_]+/mx) {
            return($cat);
        }
    }
    return("");
}

################################################################################
sub _log {
    my($fmt, @args) = @_;
    chomp($fmt);
    printf($fmt."\n", @args);
}