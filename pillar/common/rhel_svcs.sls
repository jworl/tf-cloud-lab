{% if "infantry" in grains['roles'] %}
{% set PASSAUTH = "yes" %}
{% else %}
{% set PASSAUTH = "no" %}
{% endif %}

services:
  'openssh-server': 'sshd'

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
        AcceptEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
        AcceptEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
        AcceptEnv LC_IDENTIFICATION LC_ALL LANGUAGE
        AcceptEnv XMODIFIERS

        # override default of no subsystems
        Subsystem sftp	/usr/libexec/openssh/sftp-server

        # Example of overriding settings on a per-user basis
        #Match User anoncvs
        #	X11Forwarding no
        #	AllowTcpForwarding no
        #	PermitTTY no
        #	ForceCommand cvs server

        AuthorizedKeysCommand /opt/aws/bin/eic_run_authorized_keys %u %f
        AuthorizedKeysCommandUser ec2-instance-connect
