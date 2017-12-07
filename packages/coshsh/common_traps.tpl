{% for mib in application.trap_events %}
{% set names = [] %}
{% for event in application.trap_events[mib] %}
{% if event.nagioslevel != -1 %}
{% do names.append(event.name) %}
{{ application|service(application.trap_service_prefix + "_traps_" + mib + "_" + event.name) }}
{#
  # if certain devices need special notification rules etc, add template
  use                             passive_traps,{{ application.trap_service_prefix }}_traps
#}
  use                             passive_traps
  host_name                       {{ application.host_name }}
  _MIB                            {{ event.mib }}
  _OID                            {{ event.oid|replace('\\', '') }}
}
{% endif %}
{% endfor %}
{% endfor %}
