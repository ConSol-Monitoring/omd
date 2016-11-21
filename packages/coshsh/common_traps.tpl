{% for mib in application.trap_events %}
# mib {{ mib }}
{% set names = [] %}
{% for event in application.trap_events[mib] %}
{% do names.append(event.name) %}
{{ application|service(application.trap_service_prefix + "_traps_" + mib + "_" + event.name) }}
  use                             passive_traps,{{ application.trap_service_prefix }}_traps
  host_name                       {{ application.host_name }}
  contact_groups                  bmc_t
  _MIB                            {{ event.mib }}
  _OID                            {{ event.oid|replace('\\', '') }}
  _TRAPDESC                       {{ event.trapdesc }}
}
# endevent
{% endfor %}
# endeventloop
{% endfor %}
# endmibloop

