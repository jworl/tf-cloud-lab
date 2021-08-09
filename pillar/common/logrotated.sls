logrotated:
  logs:
    salt-common:
      archive_dir: /var/log/archives/salt
      user: root
      group: root
      conf: |
        /var/log/salt/master {
            daily
            missingok
            dateext
            rotate 7
            compress
            copytruncate
            olddir /var/log/archives/salt
        }

        /var/log/salt/minion {
            weekly
            missingok
            dateext
            rotate 7
            compress
            copytruncate
            olddir /var/log/archives/salt
        }

        /var/log/salt/key {
            weekly
            missingok
            dateext
            rotate 7
            compress
            copytruncate
            olddir /var/log/archives/salt
        }
