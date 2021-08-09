# disable_firewall:
#     module.run:
#         - name: firewall.disable

disable_win_firewall:
    win_firewall.disabled:
        - name: allprofiles
