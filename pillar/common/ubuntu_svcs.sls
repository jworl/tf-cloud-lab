{% if "infantry" in grains['roles'] %}
{% set PASSAUTH = "yes" %}
{% else %}
{% set PASSAUTH = "no" %}
{% endif %}

services:
  'auditd': 'auditd'
  'ntp': 'ntp'
  'openssh-server': 'sshd'

auditd:
  /lib/systemd/system/auditd.service:
    permissions:
      - user: root
      - group: root
      - mode: 644
    content: |
        [Unit]
        Description=Security Auditing Service
        DefaultDependencies=no
        ## If auditd.conf has tcp_listen_port enabled, copy this file to
        ## /etc/systemd/system/auditd.service and add network-online.target
        ## to the next line so it waits for the network to start before launching.

        After=local-fs.target systemd-tmpfiles-setup.service
        Conflicts=shutdown.target
        Before=sysinit.target shutdown.target
        RefuseManualStop=yes
        ConditionKernelCommandLine=!audit=0

        Documentation=man:auditd(8) https://github.com/linux-audit/audit-documentation

        [Service]
        Type=forking
        PIDFile=/var/run/auditd.pid
        ExecStart=/sbin/auditd

        ## To not use augenrules, copy this file to /etc/systemd/system/auditd.service
        ## and comment/delete the next line and uncomment the auditctl line.
        ## NOTE: augenrules expect any rules to be added to /etc/audit/rules.d/

        ExecStartPost=-/sbin/augenrules --load
        #ExecStartPost=-/sbin/auditctl -R /etc/audit/audit.rules
        ExecReload=/bin/kill -HUP $MAINPID

        # By default we don't clear the rules on exit. To enable this, uncomment
        # the next line after copying the file to /etc/systemd/system/auditd.service

        #ExecStopPost=/sbin/auditctl -R /etc/audit/audit-stop.rules

        [Install]
        WantedBy=multi-user.target

ntp:
  /etc/ntp.conf:
    permissions:
      - user: root
      - group: root
      - mode: 600
    content: |
        driftfile /var/lib/ntp/ntp.drift
        leapfile /usr/share/zoneinfo/leap-seconds.list
        statistics loopstats peerstats clockstats
        filegen loopstats file loopstats type day enable
        filegen peerstats file peerstats type day enable
        filegen clockstats file clockstats type day enable
        pool time-c-g.nist.gov iburst
        pool time-b-wwv.nist.gov  iburst
        pool time-d-b.nist.gov iburst
        pool ntp.nist.gov
        restrict -4 default kod notrap nomodify nopeer noquery limited
        restrict -6 default kod notrap nomodify nopeer noquery limited
        restrict 127.0.0.1
        restrict ::1
        restrict source notrap nomodify noquery

sshd:
  /etc/ssh/sshd_config:
    permissions:
      - user: root
      - group: root
      - mode: 644
    content: |
        # This is the sshd server system-wide configuration file.  See
        # For more info: https://www.ssh.com/ssh/sshd_config/

        Port 22
        AddressFamily inet
        ListenAddress 0.0.0.0

        HostKey /etc/ssh/ssh_host_ed25519_key
        HostKey /etc/ssh/ssh_host_rsa_key
        HostKey /etc/ssh/ssh_host_ecdsa_key

        # Specifies the available KEX (Key Exchange) algorithms.
        KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256

        # Specifies the ciphers allowed
        Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr

        #Specifies the available MAC (message authentication code) algorithms
        MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com

        # Ciphers and keying
        #RekeyLimit default none

        # Logging
        #SyslogFacility AUTH
        LogLevel VERBOSE

        # Authentication:

        LoginGraceTime 1m
        PermitRootLogin no
        #StrictModes yes
        #MaxAuthTries 6
        #MaxSessions 10

        PubkeyAuthentication yes

        # Expect .ssh/authorized_keys2 to be disregarded by default in future.
        AuthorizedKeysFile	.ssh/authorized_keys

        #AuthorizedPrincipalsFile none

        #AuthorizedKeysCommand none
        #AuthorizedKeysCommandUser nobody

        HostbasedAuthentication no
        # Change to yes if you don't trust ~/.ssh/known_hosts for
        # HostbasedAuthentication
        #IgnoreUserKnownHosts no
        # Don't read the user's ~/.rhosts and ~/.shosts files
        IgnoreRhosts yes

        # To disable tunneled clear text passwords, change to no here!
        PasswordAuthentication {{ PASSAUTH }}
        PermitEmptyPasswords no

        # Change to yes to enable challenge-response passwords (beware issues with
        # some PAM modules and threads)
        ChallengeResponseAuthentication no

        # Kerberos options
        #KerberosAuthentication no
        #KerberosOrLocalPasswd yes
        #KerberosTicketCleanup yes
        #KerberosGetAFSToken no

        # GSSAPI options
        #GSSAPIAuthentication no
        #GSSAPICleanupCredentials yes
        #GSSAPIStrictAcceptorCheck yes
        #GSSAPIKeyExchange no

        # Set this to 'yes' to enable PAM authentication, account processing,
        # and session processing. If this is enabled, PAM authentication will
        # be allowed through the ChallengeResponseAuthentication and
        # PasswordAuthentication.  Depending on your PAM configuration,
        # PAM authentication via ChallengeResponseAuthentication may bypass
        # the setting of "PermitRootLogin without-password".
        # If you just want the PAM account and session checks to run without
        # PAM authentication, then enable this but set PasswordAuthentication
        # and ChallengeResponseAuthentication to 'no'.
        UsePAM yes

        #AllowAgentForwarding yes
        #AllowTcpForwarding yes
        #GatewayPorts no
        X11Forwarding yes
        #X11DisplayOffset 10
        #X11UseLocalhost yes
        #PermitTTY yes
        PrintMotd no
        #PrintLastLog yes
        #TCPKeepAlive yes
        #UseLogin no
        #PermitUserEnvironment no
        #Compression delayed
        ClientAliveInterval 300
        ClientAliveCountMax 0
        #UseDNS no
        #PidFile /var/run/sshd.pid
        #MaxStartups 10:30:100
        #PermitTunnel no
        #ChrootDirectory none
        #VersionAddendum none

        # no default banner path
        #Banner none

        # Allow client to pass locale environment variables
        AcceptEnv LANG LC_*

        # override default of no subsystems
        Subsystem	sftp	/usr/lib/openssh/sftp-server

        # Example of overriding settings on a per-user basis
        #Match User anoncvs
        #	X11Forwarding no
        #	AllowTcpForwarding no
        #	PermitTTY no
        #	ForceCommand cvs server
