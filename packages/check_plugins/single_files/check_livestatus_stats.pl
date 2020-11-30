#!/usr/bin/env perl

use warnings;
use strict;
BEGIN {
    if($ENV{OMD_ROOT}) {
        use lib $ENV{OMD_ROOT}.'/share/thruk/lib';
    }
}
use Monitoring::Livestatus::Class::Lite;
use Monitoring::Plugin;
use Getopt::Long;

my $columns = [qw/
    host_checks_rate
    service_checks_rate
    connections_rate
    requests_rate
    log_messages_rate
    forks_rate
    neb_callbacks_rate
/];

my $np = Monitoring::Plugin->new(
    shortname => "LIVESTATS",
    usage     => "Usage: %s [-s|--socket=<path>][ -c|--critical=<threshold>=<range> ] [ -w|--warning=<threshold>=<range> ]",
    version   => "v0.01",
    extra     => "\nAvailable performance counter:\n".join(", ", @{$columns}),
);

#DEFINE ARGUMENTS
$np->add_arg(
    spec    => 'socket|s=s',
    help    => '--socket|-s, f.e.: -s /path/to/socket',
    default => $ENV{OMD_ROOT} ? $ENV{OMD_ROOT}.'/tmp/run/live' : undef,
);
$np->add_arg(
    spec    => 'warning|w=s@',
    help    => 'threshold, f.e.: -w host_checks_rate=@10:20 . See https://www.monitoring-plugins.org/doc/guidelines.html#THRESHOLDFORMAT for the threshold format.',
);
$np->add_arg(
    spec    => 'critical|c=s@',
    help    => 'threshold, f.e.: -c service_checks_rate=@10:20',
);

$np->getopts();

my $class = Monitoring::Livestatus::Class::Lite->new(
    $np->opts->socket
);

my $hosts = $class->table('status');
my $c     = $hosts->columns(@{$columns})->hashref_array()->[0];
# see http://www.naemon.org/documentation/usersguide/livestatus.html

# parse thresholds
my $thresholds = {};
if($np->opts->warning) {
    for my $val (@{$np->opts->warning}) {
        if($val =~ m/^([^=]+)=(.*)/) {
            $thresholds->{$1}->{"warning"} = $2;
        } else {
            $np->plugin_die("invalid threshold format in ".$val." See help for details");
        }
    }
}
if($np->opts->critical) {
    for my $val (@{$np->opts->critical}) {
        if($val =~ m/^([^=]+)=(.*)/) {
            $thresholds->{$1}->{"critical"} = $2;
        } else {
            $np->plugin_die("invalid threshold format in ".$val." See help for details");
        }
    }
}

# add all counter as performance data
for my $col (@{$columns}) {
    $np->add_perfdata(
        label     => $col,
        value     => $c->{$col},
        uom       => "",
        threshold => $thresholds->{$col} ? $np->set_thresholds(%{$thresholds->{$col}}) : undef,
    );
}

#check thresholds
for my $key (sort keys %{$thresholds}) {
    $np->plugin_die("unknown threshold key: $key") unless defined $c->{$key};
    my $code = $np->check_threshold(
        check    => $c->{$key},
        warning  => $thresholds->{$key}->{'warning'},
        critical => $thresholds->{$key}->{'critical'},
    );
    $np->add_message($code, sprintf("%s: %.1f/s", $key, $c->{$key}));
}
if(scalar keys %{$thresholds} == 0) {
    for my $key (qw/host_checks_rate service_checks_rate/) {
        $np->add_message(OK, sprintf("%s: %.1f/s", $key, $c->{$key}));
    }
}

$np->plugin_exit($np->check_messages(join => ", "));
