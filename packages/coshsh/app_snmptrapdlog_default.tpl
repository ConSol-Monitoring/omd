{% for mib in application.mibs %}
 # i scan {{ mib }}
{{ application|service("app_snmptrapdlog_traps_" + mib + "_scan_logs") }}
  use                             os_linux_default
  host_name                       {{ application.host_name }}
  check_command                   snmptt_check_logfiles_mib_traps!60!$USER4$/etc/check_logfiles/snmptt/{{ mib }}.cfg
  notifications_enabled           0
  is_volatile                     1
  max_check_attempts              1
  check_interval                  1
  retry_interval                  1
}

{% endfor %}

{{ application|service("app_snmptrapdlog_default_check_traplog_alive") }}
  use                             srv-perf,os_linux_default
  host_name                       {{ application.host_name }}
  check_command                   snmptt_check_logfiles_config!60!$USER4$/etc/check_logfiles/check_traplog_alive.cfg
  notifications_enabled           0
  is_volatile                     0
  max_check_attempts              3
  check_interval                  5
  retry_interval                  5
}

{{ application|service("app_snmptrapdlog_default_check_snmptrapd") }}
  use                             srv-perf,os_linux_default
  host_name                       {{ application.host_name }}
  check_command                   check_proc_snmptrapd
  notifications_enabled           1
  is_volatile                     0
  max_check_attempts              3
  check_interval                  1
  retry_interval                  1
}

