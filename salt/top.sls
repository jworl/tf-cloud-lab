base:
  'owner:CTUIR':
    - match: grain
    - packages

  'G@kernel:Windows and G@owner:CTUIR':
    - match: compound
    - firewall_disable
    - win_rm

  'G@kernel:Linux and G@owner:CTUIR':
    - match: compound
    - services
    - logrotated

  'roles:infantry':
    - match: grain
    - sentinelone
    - victims
