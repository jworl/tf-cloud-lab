base:
  'G@owner:CTUIR and G@roles:infantry':
    - match: compound
    - common.sentinelone
    - common.carbonblack
    - common.victims

  'G@owner:CTUIR and G@kernel:Linux':
    - match: compound
    - common.logrotated

  'G@owner:CTUIR and G@os:Windows':
    - match: compound
    - common.windows_pkgs

  'G@owner:CTUIR and G@os:Ubuntu':
    - match: compound
    - common.ubuntu_pkgs
    - common.ubuntu_svcs
    - common.audit_rules

  'G@owner:CTUIR and G@os:CentOS':
    - match: compound
    - common.logrotated
    - common.repos
    - common.centos_pkgs
    - common.centos_svcs

  'G@owner:CTUIR and G@os:Amazon':
    - match: compound
    - common.logrotated
    - common.rhel_pkgs
    - common.rhel_svcs
