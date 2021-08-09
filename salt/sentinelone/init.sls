{% set SITE_TOKEN = pillar['sentinelone']['registrationToken'] %}

{% set URL = pillar['sentinelone']['console'] %}

{% if grains['os_family'] == 'Windows' %}
{% set INSTALLER = "s1_windows_latest.exe" %}
{% elif grains['os_family'] == 'Debian' %}
{% set INSTALLER = "s1_debian_latest.deb" %}
{% set METHOD = "dpkg -i" %}
{% elif grains['os_family'] == 'RedHat' %}
{% set INSTALLER = "s1_rhel_latest.rpm" %}
{% set METHOD = "rpm -i --nodigest" %}
{% endif %}

{% if grains['os_family'] == 'Windows' %}
s1_installer:
    file.managed:
        - name: c:\{{ INSTALLER }}
        - source: salt://files/s1/{{ INSTALLER }}
    cmd.run:
        - name: c:\{{ INSTALLER }} /SITE_TOKEN={{ SITE_TOKEN }} /q
        - unless:
            - tasklist | find "SentinelAgent.exe"
        - require:
            - file: c:\{{ INSTALLER }}
{% elif grains['kernel'] == 'Linux' %}
s1_installer:
    file.managed:
        - name: /tmp/{{ INSTALLER }}
        - source: salt://files/s1/{{ INSTALLER }}
    cmd.run:
        - name: {{ METHOD }} /tmp/{{ INSTALLER }}
        - unless:
            - /opt/sentinelone/bin/sentinelctl version
        - require:
            - file: /tmp/{{ INSTALLER }}

s1_config:
    cmd.run:
        - name: /opt/sentinelone/bin/sentinelctl management token set {{ SITE_TOKEN }}
        - unless:
            - /opt/sentinelone/bin/sentinelctl management status | grep {{ URL }}
        - require:
            - cmd: s1_installer

s1_start:
    cmd.run:
        - name: /opt/sentinelone/bin/sentinelctl control start
        - unless:
            - /opt/sentinelone/bin/sentinelctl control status
        - require:
            - cmd: s1_config
{% endif %}
