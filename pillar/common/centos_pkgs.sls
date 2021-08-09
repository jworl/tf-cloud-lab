packages:
  base:
    - 'epel-release'
    - 'bind-utils'
    - 'git'
    - 'htop'
    - 'iftop'
    - 'iotop'
    - 'ipset'
    - 'ipset-service'
    - 'lsof'
    - 'mtr'
    - 'nfs-utils'
    - 'net-tools'
    - 'patch'
    - 'pv'
    - 'rsync'
    - 'screen'
    - 'smartmontools'
    - 'strace'
    - 'sysstat'
    - 'tcpdump'
    - 'telnet'
    - 'traceroute'
    - 'tree'
    - 'vim-enhanced'
    - 'wget'
{% if grains['osfinger'] == 'CentOS Linux-7' %}
  centos7:
    - 'dstat'
    - 'iptables-services'
    - 'man-db'
    - 'python3-pip'
    - 'policycoreutils-python'
{% endif %}
{% if grains['osfinger'] == 'CentOS-6' %}
  centos6:
    - 'ftop'
    - 'man'
{% endif %}
