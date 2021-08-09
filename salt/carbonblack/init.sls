# Documentation:
# https://docs.vmware.com/en/VMware-Carbon-Black-Cloud/services/cbc-sensor-installation-guide/GUID-76272E42-E534-47AD-8654-B2F3B5682806.html
# https://community.carbonblack.com/t5/Knowledge-Base/Carbon-Black-Cloud-How-to-Deploy-the-CBC-Sensor-on-Linux/ta-p/74655
# https://community.carbonblack.com/t5/Knowledge-Base/Carbon-Black-Cloud-How-to-Designate-a-Policy-At-Install-on-Linux/ta-p/95193

{% set COMPANY_CODE = pillar['carbonblack']['company_code'] %}
{% set GROUP_NAME = pillar['carbonblack']['group_name'] %}
{% set USER_EMAIL = pillar['carbonblack']['user_email'] %}

{% if grains['os_family'] == 'Windows' %}
{% set INSTALLER = pillar['carbonblack']['Windows'] %}
{% elif grains['os_family'] == 'Debian' %}
{% set INSTALLER = pillar['carbonblack']['Debian'] %}
{% elif grains['os_family'] == 'RedHat' %}
{% set INSTALLER = pillar['carbonblack']['RedHat'] %}
{% endif %}

{% if grains['os_family'] == 'Windows' %}
cbth_installer:
    file.managed:
        - name: c:\{{ INSTALLER }}
        - source: salt://files/cbth/{{ INSTALLER }}
    cmd.run:
        - name: msiexec.exe /q /i c:\{{ INSTALLER }} COMPANY_CODE="{{ COMPANY_CODE }}" GROUP_NAME="{{ GROUP_NAME }}" USER_EMAIL="{{ USER_EMAIL }}"
        - unless:
            - tasklist | find "RepMgr.exe"
        - require:
            - file: c:\{{ INSTALLER }}
{% elif grains['kernel'] == 'Linux' %}
cbth_installer:
    archive.extracted:
        - name: /tmp/cb-psc-install
        - source: salt://files/cbth/{{ INSTALLER }}
        - enforce_toplevel: false
    cmd.run:
        - name: /tmp/cb-psc-install/{{ INSTALLER }}
        - unless:
            - test -f /opt/carbonblack/psc/bin/cbagentd
        - require:
            - archive: /tmp/cb-psc-install


cbth_config:
    cmd.run:
        - name: /opt/carbonblack/psc/bin/cbagentd -d '{{ COMPANY_CODE }}'
        - require:
            - cmd: /tmp/cb-psc-install/{{ INSTALLER }}
    file.line:
        - name: /var/opt/carbonblack/psc/cfg.ini
        - content: GroupName={{ GROUP_NAME }}
        - after: InstallPackageType
        - mode: ensure
        - require:
            - cmd: /tmp/cb-psc-install/{{ INSTALLER }}
    service.running:
        - name: cbagentd
        - enable: true
        - watch:
            - file: /var/opt/carbonblack/psc/cfg.ini
{% endif %}
