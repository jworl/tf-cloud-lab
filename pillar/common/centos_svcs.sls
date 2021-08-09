{% if grains.selinux.enabled %}
selinux:
  collectd:
    - nis_enabled
    - collectd_tcp_network_connect
{% endif %}

services:
  'at': 'atd'
