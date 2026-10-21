# {{ mib.mib }} {{ mib.miblabel }}
# common prefix {{ mib.common_prefix }}
my $VERBOSE = 0;
our @commands = ();
# sender address => [host_name, service prefix, mib (or its alias)]
my %agents = (
{% for ip, pointer in mib.sorted_agents %}
  '{{ ip }}' => ["{{ pointer[0] }}", "{{ pointer[1] }}", "{{ pointer[2] }}"],
{% endfor %}
);
{% if mib.mib == "RAGPICKER-MIB" %}
# "<sender address> <trap oid>" of all the traps which are handled elsewhere
my %expected_traps = (
{% for ip_oid in mib.expected_traps %}
  '{{ ip_oid }}' => 1,
{% endfor %}
);
{% endif %}

sub get_host_from_ip {
  my ($ip) = @_;
  return $agents{$ip};
}

{% if mib.mib == "RAGPICKER-MIB" %}
sub find_ip_oid_combi {
  my ($ip, $oid) = @_;
  return exists $expected_traps{$ip.' '.$oid};
}

{% endif %}
sub prepare_submit_command {
  my ($address, $trap, $recovers, $severity, $text) = @_;
  $text =~ s/[^[:ascii:]]//g;
  $trap =~ s/[^[:ascii:]]//g;;
  if (my $info = get_host_from_ip($address)) {
{#
    Folgendes ist moeglich: Der Host implementiert die alte Mib,
    seine Traps werden also vom trapfile-Scanner ISILON-TRAP-2014-MIB entdeckt.
    Seine Services lauten aber ...traps_ISILON-TRAP-MIB_...,
    daher muss get_host_from_ip auch die Alias-Mib [2] liefern.
    '10.14.6.67' => ['itaemc01c1.mygroup.net', 'os_isilon', 'ISILON-TRAP-MIB'],
#}
    my $command = sprintf "COMMAND [%d] PROCESS_SERVICE_CHECK_RESULT;%s;%s;%d;%s",
        time, $info->[0],
        $info->[1].'_traps_'.$info->[2].'_'.$trap,
        $severity,
        $text;
    push(@commands, $command) if $severity != -1;
    if ($recovers) {
      # alle bisherigen <dieserhost>;recovers aus commands loeschen
      # alle, nicht-ok, aber auch die ok. Ist zwar schade um die Historie
      # aber wer's genau wissen will, muss sich durch die traps.log fressen
      my $to_delete = sprintf ";%s;%s;", $info->[0], $info->[1].'_traps_'.$info->[2].'_'.$recovers;
      @commands = map {
        if (index($_, $to_delete) == -1) {
          $_;
        } elsif (index($_, 'UN') == 0) {
          $_; # already UN
        } else {
          'UN'.$_;
        }
      } @commands;
      my $command = sprintf "COMMAND [%d] PROCESS_SERVICE_CHECK_RESULT;%s;%s;%d;%s",
          time, $info->[0],
          $info->[1].'_traps_'.$info->[2].'_'.$recovers,
          0,
          'recovered by '.$trap.($severity == -1 ? ' ('.$text.')' : '');
      push(@commands, $command);
    }
  }
  return $text;
}

sub parse_varbinds {
  # ".1.3.6.1.2.1.1.5.0 nagiosnode01____.1.3.6.1.4.1.43420.9999.1.0 "Test"____...
  # becomes ('nagiosnode01', '"Test"', ...)
  my ($subtraps) = @_;
  return map { /^[\d\.]+\s+(.*)$/ ? $1 : '' } split(/____/, $subtraps);
}

sub snmptt_resolve {
  my ($text, $varbinds) = @_;
  my $all = join(", ", @{$varbinds});
  # $n is the n-th varbind value, $* all of them
  $text =~ s/\$(\d+|\*)/
    $1 eq '*' ? $all :
    ($1 >= 1 && $1 <= scalar(@{$varbinds})) ? $varbinds->[$1-1] : '$'.$1
  /ge;
  return $text;
}

sub compile_rule {
  # turns a MATCH rule into a sub which gets the varbind values.
  # called once per rule when the config is loaded, not per trap.
  my ($rule) = @_;
  if ($rule =~ /^\$(\d+):\s*!\s*(\w+)\s*$/) {
    # MATCH $x: ! n
    my ($idx, $value) = ($1-1, $2);
    return sub { $_[0]->[$idx] ne $value };
  } elsif ($rule =~ /^\$(\d+):\s*(\w+)\s*$/) {
    # MATCH $x: n
    my ($idx, $value) = ($1-1, $2);
    return sub { $_[0]->[$idx] eq $value };
  } elsif ($rule =~ /^\$(\d+):\s*!\s*\((.*)\)\s*i\s*$/) {
    # MATCH $x: ! (reg) i
    my ($idx, $regex) = ($1-1, qr/$2/i);
    return sub { $_[0]->[$idx] !~ $regex };
  } elsif ($rule =~ /^\$(\d+):\s*!\s*\((.*)\)\s*$/) {
    # MATCH $x: ! (reg)
    my ($idx, $regex) = ($1-1, qr/$2/);
    return sub { $_[0]->[$idx] !~ $regex };
  } elsif ($rule =~ /^\$(\d+):\s*\((.*)\)\s*i\s*$/) {
    # MATCH $x: (reg) i
    my ($idx, $regex) = ($1-1, qr/$2/i);
    return sub { $_[0]->[$idx] =~ $regex };
  } elsif ($rule =~ /^\$(\d+):\s*\((.*)\)\s*$/) {
    # MATCH $x: (reg)
    my ($idx, $regex) = ($1-1, qr/$2/);
    return sub { $_[0]->[$idx] =~ $regex };
  } elsif ($rule =~ /^\$(\d+):\s*!\s*<\s*(\d+)\s*$/) {
    # MATCH $x: ! < n
    my ($idx, $value) = ($1-1, $2);
    return sub { $_[0]->[$idx] >= $value };
  } elsif ($rule =~ /^\$(\d+):\s*<\s*(\d+)\s*$/) {
    # MATCH $x: < n
    my ($idx, $value) = ($1-1, $2);
    return sub { $_[0]->[$idx] < $value };
  } elsif ($rule =~ /^\$(\d+):\s*!\s*>\s*(\d+)\s*$/) {
    # MATCH $x: ! > n
    my ($idx, $value) = ($1-1, $2);
    return sub { $_[0]->[$idx] <= $value };
  } elsif ($rule =~ /^\$(\d+):\s*>\s*(\d+)\s*$/) {
    # MATCH $x: > n
    my ($idx, $value) = ($1-1, $2);
    return sub { $_[0]->[$idx] > $value };
  } elsif ($rule =~ /^\$(\d+):\s*!\s*(\d+)-(\d+)\s*$/) {
    # MATCH $x: ! n-n
    my ($idx, $low, $high) = ($1-1, $2, $3);
    return sub { $_[0]->[$idx] < $low || $_[0]->[$idx] > $high };
  } elsif ($rule =~ /^\$(\d+):\s*(\d+)-(\d+)\s*$/) {
    # MATCH $x: n-n
    my ($idx, $low, $high) = ($1-1, $2, $3);
    return sub { $_[0]->[$idx] >= $low && $_[0]->[$idx] <= $high };
  } else {
    printf STDERR "unknown rule __%s__\n", $rule;
    return sub { 0 };
  }
}

sub compile_rules {
  my ($rules) = @_;
  return [ map { compile_rule($_) } split("____", $rules) ];
}

sub match_matches {
  my ($mode, $rules, $values) = @_;
  my $rulehits = grep { $_->($values) } @{$rules};
  return 1 if $mode eq 'and' && $rulehits == scalar(@{$rules}); # all of them
  return 1 if $mode eq 'or' && $rulehits; # any of them
  return 0;
}

{% if mib.mib != "RAGPICKER-MIB" %}
# Events of this MIB. An event with MATCH entries in the snmptt file has
# them in "matches": [nagios level, mode, rules, FORMAT], first hit wins.
my @event_list = (
{% for event in mib.events %}
  {
    oid => '{{ event.oid }}',
    name => '{{ event.name }}',
    text => '{{ event.text }}',
    recovers => '{{ event.recovers or "" }}',
    nagioslevel => {{ event.nagioslevel }},
    matches => [
{%   for match in event.matches or [] %}
      [{{ match[0] }}, '{{ match[1] }}', compile_rules('{{ match[2] }}'), '{{ match[3] }}'],
{%   endfor %}
    ],
  },
{% endfor %}
);
# trap oid => event. If several events have the same oid, the first one counts.
my %events = ();
foreach my $event (@event_list) {
  $events{$event->{oid}} = $event unless exists $events{$event->{oid}};
}

{% endif %}
$options = 'report=short,supersmartpostscript';

@searches = (
{
  tag => '{{ mib.mib }}',
  logfile => $ENV{OMD_ROOT}.'/var/log/snmp/traps.log',
  rotation => '^%s\.((1)|([2-9]+\.gz))$',
{% if mib.trap_oid_filter %}
  prefilter => '{{ mib.trap_oid_filter }}',
{% endif %}
  criticalpatterns => '^\[(.*?)\] summary: .*?UDP: \[([\.\d]+)\].*?____([\.\d]+ .*?)____\.1\.3\.6\.1\.6\.3\.1\.1\.4\.1\.0\s+([\.\d]+)____(.*)$',
  script => sub {
    my $address = $ENV{CHECK_LOGFILES_CAPTURE_GROUP2};
    my $trap_oid = $ENV{CHECK_LOGFILES_CAPTURE_GROUP4};
    my $flat_trap = $ENV{CHECK_LOGFILES_CAPTURE_GROUP.$ENV{CHECK_LOGFILES_CAPTURE_GROUPS}};
{% if mib.mib == "RAGPICKER-MIB" %}
    return 0 if find_ip_oid_combi($address, $trap_oid); # this trap is wanted, ignore it here
    my $sub = prepare_submit_command($address, 'unexpectedTrap', '',
        {{ mib.unexpected_level }}, 'received unexpected oid: '.$trap_oid);
{% else %}
    my $event = $events{$trap_oid};
    return 0 if ! $event;
    my @varbinds = parse_varbinds($flat_trap);
    my $severity = $event->{nagioslevel};
    my $text = $event->{text};
    if (@{$event->{matches}}) {
      # MATCH rules compare the values without surrounding quotes
      my @values = map { /^"(.*)"$/ ? $1 : $_ } @varbinds;
      foreach my $match (@{$event->{matches}}) {
        my ($level, $mode, $rules, $format) = @{$match};
        if (match_matches($mode, $rules, \@values)) {
          ($severity, $text) = ($level, $format);
          last;
        }
      }
    }
    my $sub = prepare_submit_command($address, $event->{name}, $event->{recovers},
        $severity, snmptt_resolve($text, \@varbinds));
{% endif %}
    printf "sub %s\n", $sub;
    return 2;
  },
  options => 'supersmartscript,capturegroups,noprotocol,noperfdata',
},
{#
{
  tag => 'UnknownTraps',
  logfile => $ENV{OMD_ROOT}.'/var/log/snmp/traps.log',
  rotation => '^%s\.((1)|([2-9]+\.gz))$',
  criticalpatterns => '^\[(.*?)\] summary: .*UDP: \[([\.\d]+)\].*?____(.*)$',
  criticalexceptions => [
{% for event in mib.events %}
    '^\[(.*?)\] summary: .*UDP: \[([\.\d]+)\].*?____([\.\d]+ \d+)____\.1\.3\.6\.1\.6\.3\.1\.1\.4\.1\.0 [\.]*{{ event.oid }}____(.*)$',
{% endfor %}
  ],
  script => sub {
    my $address = $ENV{CHECK_LOGFILES_CAPTURE_GROUP2};
    my $flat_trap = $ENV{CHECK_LOGFILES_CAPTURE_GROUP.$ENV{CHECK_LOGFILES_CAPTURE_GROUPS}};
    if (my $info = Monitoring::Trap::HostSNMPTrapinfo::get_host_from_ip($address)) {
      print $flat_trap;
      return 2;
    } else {
      return 0; # unknown host, ignore
    }
  },
  options => 'supersmartscript,capturegroups,noprotocol,noperfdata',
}
#}
);

$postscript = sub {
  if (@commands) {
    my $submitted = 0;
    my $last_command = "";
    if (scalar(@commands)) {
      open SPOOL, ">".$ENV{OMD_ROOT}.'/tmp/{{ mib.mib }}.cmds';
      foreach (map { /COMMAND (.*)/; $1; } grep { /^COMMAND/ } @commands) {
        if ($_ eq $last_command) {
          next;
        } else {
          printf SPOOL "%s\n", $_;
          $submitted++;
          $last_command = $_;
        }
      }
      close SPOOL;
      if ("{{ mib.extcmd }}" eq "nagios.cmd") {
        open CMD, ">".$ENV{OMD_ROOT}.'/tmp/run/nagios.cmd';
        printf CMD "[%lu] PROCESS_FILE;%s;1\n", time, $ENV{OMD_ROOT}.'/tmp/{{ mib.mib }}.cmds';
        close CMD;
      } elsif ("{{ mib.extcmd }}" eq "naemon.cmd") {
        open CMD, ">".$ENV{OMD_ROOT}.'/tmp/run/naemon.cmd';
        printf CMD "[%lu] PROCESS_FILE;%s;1\n", time, $ENV{OMD_ROOT}.'/tmp/{{ mib.mib }}.cmds';
        close CMD;
      }
      #open CMD, ">".$ENV{OMD_ROOT}.'/tmp/run/live';
    }
    if ($submitted) {
      printf "OK - found %d traps (%d submitted) | traps=%d submitted=%d\n", scalar(@commands), $submitted, scalar(@commands), $submitted;
      printf "%s\n", join("\n", @commands);
      return 0;
    } else {
      printf "OK - found %d traps, all of them were harmless\n", scalar(@commands);
      return 0;
    }
  } else {
    printf "OK - found no new traps | traps=0 submitted=0\n";
    return 0;
  }
};

