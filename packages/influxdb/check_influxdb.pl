#!/usr/bin/env perl

use strict;
use warnings;
use Monitoring::Plugin;
use JSON::XS;

chdir($ENV{'OMD_ROOT'});
my $np     = Monitoring::Plugin->new(shortname => "INFLUXDB SIZE",
                                     usage => "Usage: %s [ -v|--verbose ]  [-t <timeout>] "
                                             ."[ -c|--critical=<threshold> ] [ -w|--warning=<threshold> ]",
);
my $folder = 'var/influxdb/';
my $db     = 'nagflux';

$np->add_arg(
    spec    => 'warning|w=s',
    help    => '-w, --warning=INTEGER:INTEGER. See https://www.monitoring-plugins.org/doc/guidelines.html#THRESHOLDFORMAT for the threshold format.',
    default => '1GB',
);
$np->add_arg(
    spec    => 'critical|c=s',
    help    => '-c, --critical=INTEGER:INTEGER.',
    default => '2GB',
);
$np->getopts();
$np->set_thresholds(warning  => _expand($np->opts->warning),
                    critical => _expand($np->opts->critical));

my $total;
my $data = `du -b -d1 -t 1 $folder`;
for my $row (split/\n/mx, $data) {
    my($size,$path) = split(/\s+/mx, $row, 2);
    $path =~ s|^.*/||mx;
    if($path) {
        $np->add_perfdata(
            label => $path,
            value => $size,
            uom   => "B",
        );
    } else {
        $np->add_perfdata(
            label => 'total',
            value => $size,
            uom   => "B",
            threshold => $np->threshold,
        );
        $total = $size;
    }
}

chomp(my $influxdb_http_tcp_port = `grep CONFIG_INFLUXDB_HTTP_TCP_PORT ./etc/omd/site.conf`);
$influxdb_http_tcp_port =~ s/^.*'(\d+)'.*$/$1/mx;
my $cmd = 'curl -s -S -G "http://localhost:'.$influxdb_http_tcp_port.'/query?db='.$db.'&u=root&p=root&pretty=true" --data-urlencode "q=SELECT COUNT(value) FROM /./" 2>&1';
my $entrie_json = `$cmd`;
if($? != 0) {
    $np->plugin_exit(CRITICAL, $entrie_json);
}
else {
    my $entries = decode_json($entrie_json);
    for my $series (@{$entries->{'results'}->[0]->{'series'}}) {
        my %values;
        @values{@{$series->{'columns'}}} = @{$series->{'values'}->[0]};
        $np->add_perfdata(
            label => $series->{'name'},
            value => $values{'count'},
        );
    }
}


my $code = $np->check_threshold(
    check    => $total,
    warning  => $np->threshold->warning,
    critical => $np->threshold->critical,
);
$np->plugin_exit($code, sprintf("$folder total disk usage: %1.fmb", $total/1024/1024));

sub _expand {
    my($val) = @_;
    if($val =~ m/^(.*):(.*)$/mx) {
        return(_expand($1).':'._expand($2));
    }
    if($val =~ m/^([\d\.]+)(\w+)$/mx) {
        $val = $1;
        my $unit = lc($2);
        if($unit eq 'tb') { return($val*1024*1024*1024*1024); }
        if($unit eq 'gb') { return($val*1024*1024*1024); }
        if($unit eq 'mb') { return($val*1024*1024); }
        if($unit eq 'kb') { return($val*1024); }
    }
    return($val);
}
