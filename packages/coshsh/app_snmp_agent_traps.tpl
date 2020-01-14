{{ application|service("app_snmp_agent_traps_RAGPICKER-MIB_unexpectedTrap") }}
  use                             passive_traps
  host_name                       {{ application.host_name }}
  notifications_enabled           0
}
