{% set sorted_modules = application.snmp_exporter_modules %}
{% set combined_modules = sorted_modules|join("__") %}
{% set snmp_exporter_modules = [] %}
{% do snmp_exporter_modules.append(combined_modules) %}
{% for module in snmp_exporter_modules %}
- targets:
    - {{ application.host.address }}
  labels:
    instance: {{ application.host_name }}
    os_type: "{{ application.type }}"
    snexip: "{{ application.snmp_exporter_address }}"
    snexport: "{{ application.snmp_exporter_port }}"
{% if application.loginsnmpv2.community.startswith("snmpv3") %}
{% set sep = application.loginsnmpv2.community[6] %}
{% set list = application.loginsnmpv2.community.split(sep) %}
    snmpVersion: 3
{% if not list[2] and not list[4] %}
    snmpSecurityLevel: "noAuthNoPriv"
{% elif list[2] and not list[4] %}
    snmpSecurityLevel: "authNoPriv"
{% elif list[2] and list[4] %}
    snmpSecurityLevel: "authPriv"
{% endif %}
{% if list[1] %}
    snmpAuthProtocol: "{{ list[1]|re_sub('\d*$', '') }}"
{% endif %}
{% if list[2] %}
    snmpPassword: "{{ list[2] }}"
{% endif %}
{% if list[3] %}
    snmpPrivProtocol: "{{ list[3] }}"
{% endif %}
{% if list[4] %}
    snmpPrivPassword: "{{ list[4] }}"
{% endif %}
{% if list[5] %}
    snmpUsername: "{{ list[5] }}"
{% endif %}
{% if list[6] %}
    snmpContext: "{{ list[6] }}"
{% endif %}
{% else %}
    snmpCommunity: "{{ application.loginsnmpv2.community }}"
{% endif %}
    module: "{{ module }}"

{% endfor %}

