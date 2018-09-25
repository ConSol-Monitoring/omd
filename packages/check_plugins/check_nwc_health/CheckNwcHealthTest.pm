package Monitoring::GLPlugin::SNMP::MibsAndOids::CNWCHTESTMIB;

$Monitoring::GLPlugin::SNMP::MibsAndOids::origin->{'CNWCH-TEST-MIB'} = {
  url => '',
  name => 'CNWCH-TEST-MIB',
};

#$Monitoring::GLPlugin::SNMP::MibsAndOids::mib_ids->{'CNWCH-TEST-MIB'} =

$Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'CNWCH-TEST-MIB'} = {
  nwcCounter => '1.2.3.4.5.6.7.8.9',
  nwcStatus => '1.2.3.4.5.6.7.8.10',
  nwcStatusDefinition => 'CNWCH-TEST-MIB::status',
};

$Monitoring::GLPlugin::SNMP::MibsAndOids::definitions->{'CNWCH-TEST-MIB'} = {
  status => {
    '0' => 'ok',
    '1' => 'failed',
  },
};

package MyNwc;
our @ISA = qw(Monitoring::GLPlugin::SNMP);

sub init {
  my ($self) = @_;
  if ($self->mode =~ /my::nwc::test/) {
    $self->analyze_and_check_interface_subsystem("MyNwc::Status");
  }
}

package MyNwc::Status;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  my @all_cpu_metrics = qw(nwcCounter nwcStatus);
  $self->get_snmp_objects('CNWCH-TEST-MIB', @all_cpu_metrics);
  $self->valdiff({name => 'cpu'}, @all_cpu_metrics);
}

sub check {
  my ($self) = @_;
  $self->add_ok(sprintf "status is %s", $self->{nwcStatus});
  $self->set_thresholds(
    metric => "dlt",
    warning => 5,
    critical => "10:",
  );
  $self->add_message($self->check_thresholds(metric => "dlt",
      value => $self->{delta_nwcCounter}),
      sprintf "delta_counter is %d", $self->{delta_nwcCounter}
  );
  $self->add_perfdata(
    label => "dlt",
    value => $self->{delta_nwcCounter},
    uom => "s",
  );
}

