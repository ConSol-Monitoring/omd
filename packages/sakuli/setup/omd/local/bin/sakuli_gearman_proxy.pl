#!/usr/bin/perl
# vim: expandtab:ts=4:sw=4:syntax=perl

# Gearman proxy script for Sakuli checks
# This proxy enables you to rewrite Sakuli results
# Based on gearman_proxy.pl, modified by Simon Meggle <simon.meggle@consol.de>
# See https://github.com/ConSol/sakuli for more information.

use warnings;
use strict;
use MIME::Base64;
use Gearman::Worker;
use Gearman::Client;
use threads;
use Pod::Usage;
use Getopt::Long;
use Data::Dumper;
use Monitoring::Livestatus;

our $pidFile;
our $logFile;
our $queues;
our $debug;
our $livestatus = $ENV{OMD_ROOT}.'/tmp/run/live';
our ($err_h,$err_s,$err_r);

my $configFile;
my $help;
my $cfgFiles = [
    '~/.gearman_proxy',
    '/etc/mod-gearman/gearman_proxy.cfg',
];

if(defined $ENV{OMD_ROOT}) {
    push @{$cfgFiles}, $ENV{OMD_ROOT}.'/etc/mod-gearman/proxy.cfg';
}
GetOptions ('p|pid=s'    => \$pidFile,
            'l|log=s'    => \$logFile,
            'c|config=s' => \$configFile,
            'd|debug'    => \$debug,
            'h'          => \$help,
);
pod2usage(-exitval => 1) if $help;
if($configFile) {
    die("$configFile: $!") unless -r $configFile;
    $cfgFiles = [ $configFile ];
}

for my $cfgFile (@{$cfgFiles}) {
    ($cfgFile) = glob($cfgFile);
    out("looking for config file in ".$cfgFile) if $debug;
    next unless defined $cfgFile;
    next unless -f $cfgFile;

    out("reading config file ".$cfgFile) if $debug;
    do "$cfgFile";
    last;
}

my $listOfVariables = {
    'pidFile'    => $pidFile,
    'logFile'    => $logFile,
    'debug'      => $debug,
    'queues'     => $queues,
    'config'     => $configFile,
    'livestatus' => $livestatus,
    'err_h'      => $err_h,
    'err_s'      => $err_s,
    'err_r'      => $err_r,
};
out('starting...');
out('startparam:');
out($listOfVariables);

if(!defined $queues or scalar keys %{$queues} == 0) {
    out('ERROR: no queues set!');
    exit 1;
}

#################################################
# save pid file
if($pidFile) {
    open(my $fhpid, ">", $pidFile) or die "open $pidFile failed: ".$!;
    print $fhpid $$;
    close($fhpid);
}

#################################################
# create worker
my $workers = {};
for my $conf (keys %{$queues}) {
    my($server,$queue) = split/\//, $conf, 2;
    my $worker = $workers->{$server};
    unless( defined $worker) {
        $worker = Gearman::Worker->new(job_servers => [ $server ]);
        $workers->{$server} = $worker;
    }
    my $ml = Monitoring::Livestatus->new(
        keepalive => 1,
        socket => $livestatus
    );

    $worker->register_function($queue => sub { forward_job($ml, $queues->{$conf}, @_) } );
}
my $clients = {};

# start all worker
my $threads = [];
for my $worker (values %{$workers}) {
    #push @{$threads}, threads->create('worker', $worker);
    $worker->work while 1;
}

# wait till worker finish (hopefully never)
for my $thr (@{$threads}) {
    $thr->join();
}
unlink($pidFile) if $pidFile;
exit;

#################################################
# SUBS
#################################################
sub worker {
    my $worker = shift;
    $worker->work while 1;
}

#################################################
sub forward_job {
    my $ls = shift;
    my($target,$job) = @_;
    my($server,$queue) = split/\//, $target, 2;

    out($job->handle." -> ".$target) if $debug;

    my $decoded = MIME::Base64::decode(${$job->{argref}});

    out("<<<<<<<<<<<<<<<") if $debug;
    out("Decoded package:") if $debug;
    out(substr($decoded,0,500) . " ...") if $debug;
    (my $h) = $decoded =~ m/host_name=(.*)\n/;
    (my $s) = $decoded =~ m/service_description=(.*)\n/;
    (my $r) = $decoded =~ m/return_code=(.*)\n/;
    (my $o) = $decoded =~ m/output=(.*)/;
    $decoded =~ s/\n/####/g;
    if($s && !service_exists($h, $s, $ls)) {
        # Missing service
        out("MISSING HOST/SERVICE!!");
        $decoded =~ s/host_name=.*\n/host_name=$err_h\n/;
        $decoded =~ s/service_description.*\n/service_description=$err_s\n/;
        $decoded =~ s/return_code=.*\n/return_code=$err_r\n/;
        $decoded =~ s/output=.*\\n/output=Ergebnis für Prüfung $s an $h hat kein Monitoring-Objekt!\\\\n/;
    } else {
#
# $decoded is the raw gearman package data. You can do here what you want.
#
        $decoded =~ s/output=\[OK\] Sakuli suite (.*) ok.*\\n/output=Der IT-Service $1 steht ohne Einschränkung zur Verfügung.\\n/;
        $decoded =~ s/output=\[WARN\] Sakuli suite (.*) warning in step.*\\n/Der IT-Service $1 weist aktuell Performance-Probleme auf und steht nicht in gewohnter Qualität zur Verfügung./;
        $decoded =~ s/return_code=1(.*)output=\[WARN\] Sakuli suite (.*) warning in step.*\\n/return_code=2$1output=Der IT-Service $2 weist aktuell Performance-Probleme auf und steht nicht in gewohnter Qualität zur Verfügung./;
        $decoded =~ s/output=\[CRIT\] Sakuli suite (.*) critical in case.*\\n/output=Störung des IT-Service $1 erkannt. Ein Prüfschritt hat die vorgegebene Maximalzeit überschritten.\\n/;
        $decoded =~ s/output=\[CRIT\] Sakuli suite (.*) \(\d+\.\d+s\) EXCEPTION.*STEP (.*?): .*\\n/output=Störung des IT-Service $1 erkannt. Festgestellt in Prüfschritt $2.\\n/;
        $decoded =~ s/output=\[CRIT\] Sakuli suite (.*) \(\d+\.\d+s\) EXCEPTION.*CASE (.*?): .*\\n/output=Störung des IT-Service $1 erkannt. Festgestellt in Prüfschritt $2.\\n/;
        $decoded =~ s/output=\[CRIT\] Sakuli suite (.*) \(\d+\.\d+s\) EXCEPTION.*Script did not start within 150 seconds.*\\n/output=Die Pruefung des IT-Services $1 wurde ausgesetzt und wird innerhalb des definierten Anwender-Nutzungszeitraums erneut ausgefuehrt. \\n/;
    }
    $decoded =~ s/####/\n/g;

    out("---------------") if $debug;
    out("Replaced package: ") if $debug;
    out(substr($decoded,0,500) . " ...") if $debug;
    out(">>>>>>>>>>>>>>>") if $debug;
    ${$job->{argref}} = MIME::Base64::encode($decoded);

    my $client = $clients->{$server};
    unless( defined $client) {
        $client = Gearman::Client->new(job_servers => [ $server ]);
        $clients->{$server} = $client;
    }

    $client->dispatch_background($queue, $job->arg, { uniq => $job->handle });
    return;
}


#################################################

#################################################
sub out {
    my($txt) = @_;
    return unless defined $txt;
    if(ref $txt) {
        return(out(Dumper($txt)));
    }
    chomp($txt);
    my @txt = split/\n/,$txt;
    if($logFile) {
        open (my $fh, ">>", $logFile) or die "open $logFile failed: ".$!;
        for my $t (@txt)  {
            print $fh localtime(time)." ".$t,"\n";
        }
        close ($fh);
    } else {
        for my $t (@txt)  {
            print localtime(time)." ".$t."\n";
        }
    }
    return;
}


#################################################
sub service_exists {
    my ($host, $service, $ls) = @_;
    my $ls_res;
    my $retries = 5;
    while($retries > 0) {
        eval {
            $ls_res = $ls->selectrow_hashref("GET services\nColumns: description\nFilter: host_name = $host\nFilter: description = $service");
        };
        if(!$@) {
            last;
        }
        if($retries == 1) {
            out("failed to fetch service details: ".$@);
            return 1;
        }
        sleep(1);
        $retries--;
    }
    $ls_res ? return 1 : return 0;
}
