package Monitoring::Trap::Hostinfo;

sub get_host_from_ip {
  my ($ip, $mib) = @_;
  my $hosts = {
{% for host in info.combinations %}
    '{{ host.address }}' => {
{% for mib in host.mibs %}
{%   if host.unalias_mib %}
        '{{ host.unalias_mib[mib] }}' => ['{{ host.host_name }}', '{{ host.trap_service_prefix }}', '{{ mib }}'],
{%   else %}
        '{{ mib }}' => ['{{ host.host_name }}', '{{ host.trap_service_prefix }}', '{{ mib }}'],
{%   endif %}
{% endfor %}
    },
{% endfor %}
  };
  if (exists $hosts->{$ip} && exists $hosts->{$ip}->{$mib}) {
    return $hosts->{$ip}->{$mib};
  } else {
    return undef;
  }
}

1;
# ipaddress => hostname => { mibname: prefix, mibname: prefix
# ipaddress => { mibname: [hostname,prefix], mibname: prefix
