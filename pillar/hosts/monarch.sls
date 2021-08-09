#!jinja|yaml

iptables:
  filter:
    INPUT:
      1services:
        -
          - jump: ACCEPT
          - connstate: NEW
          - dports: 4505,4506
          - proto: tcp
          - match-set: SELF dst

sshd_config:
  root_login: false
