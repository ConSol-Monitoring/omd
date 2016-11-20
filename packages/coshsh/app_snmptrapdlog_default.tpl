{% for mib in application.mibs %}
 # i scan {{ mib }}
{{ application|service("app_snmptrapdlog_traps_" + mib + "_scan_logs") }}
  use                             os_linux_default
  host_name                       {{ application.host_name }}
  check_command                   check_logfiles_mib_traps!60!$USER4$/etc/check_logfiles/snmptt/{{ mib }}.cfg
  notifications_enabled           0
  is_volatile                     1
  max_check_attempts              1
  check_interval                  1
  retry_interval                  1
}

{% endfor %}
