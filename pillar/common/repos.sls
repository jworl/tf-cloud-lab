repos:
  _RPM-GPG-KEYS:
    /etc/pki/rpm-gpg/RPM-GPG-KEY-ZABBIX-A14FE591:
      permissions:
        - user: root
        - group: root
        - mode: 644
      content: |
          -----BEGIN PGP PUBLIC KEY BLOCK-----
          Version: GnuPG v1.4.10 (GNU/Linux)

          mQENBFeIdv0BCADAzkjO9jHoDRfpJt8XgfsBS8FpANfHF2L29ntRwd8ocDwxXSbt
          BuGIkUSkOPUTx6i/e9hd8vYh4mcX3yYpiW8Sui4aXbJu9uuSdU5KvPOaTsFeit9j
          BDK4b0baFYBDpcBBrgQuyviMAVAczu5qlwolA/Vu6DWqah1X9p+4EFa1QitxkhYs
          3br2ZGy7FZA3f2sZaVhHAPAOBSuQ1W6tiUfTIj/Oc7N+FBjmh3VNfIvMBa0E3rA2
          JlObxUEywsgGo7FPWnwjZyv883slHp/I3H4Or9VBouTWA2yICeROmMwjr4mOZtJT
          z9e4v/a2cG/mJXgxCe+FjBvTvrgOVHAXaNwLABEBAAG0IFphYmJpeCBMTEMgPHBh
          Y2thZ2VyQHphYmJpeC5jb20+iQE4BBMBAgAiBQJXiHb9AhsDBgsJCAcDAgYVCAIJ
          CgsEFgIDAQIeAQIXgAAKCRAIKrVroU/lkbO8B/4/MhxoUN2RPmH7BzFGIntKEWAw
          bRkDzyQOk9TjXVegfsBnzmDSdowh7gyteVauvr62jiVtowlE/95vbXqbBCISLqKG
          i9Wmbrj7lUXBd2sP7eApFzMUhb3G3GuV5pCnRBIzerDfhXiLE9EWRN89JYDxwCLY
          ctQHieZtdmlnPyCbFF6wcXTHUEHBPqdTa6hvUqQL2lHLFoduqQz4Q47Cz7tZxnbr
          akAewEToPcjMoteCSfXwF/BRxSUDlN7tKFfBpYQawS8ZtN09ImHOO6CZ/pA0qQim
          iNiRUfA25onIDWLLY/NMWg+gK94NVVZ7KmFG3upDB5/uefK6Xwu2PsgiXSQguQEN
          BFeIdv0BCACZgfqgz5YoX+ujVlw1gX1J+ygf10QsUM9GglLEuDiSS/Aa3C2UbgEa
          +N7JuvzZigGFCvxtAzaerMMDzbliTqtMGJOTjWEVGxWQ3LiY6+NWgmV46AdXik7s
          UXM155f1vhOzYp6EZj/xtGvyUzTLUkAlnZNrhEUbUmOhDLassVi32hIyMR5W7w6I
          Ii0zIM1mSuLR0H6oDEpR3GzuGVHGj4/sLeAg7iY5MziGwySBQk0Dg0xH5YqHb+uK
          zCTH/ILu3srPJq+237Px/PctAZCEA96ogc/DNF2XjdUpMSaEybR0LuHHstAqkrq8
          AyRtDJNYE+09jDFdUIukhErLuo1YPWqFABEBAAGJAR8EGAECAAkFAleIdv0CGwwA
          CgkQCCq1a6FP5ZH8+wf/erZneDXqM6xYT8qncFpc1GtOCeODNb19Ii22lDEXd9qN
          UlAz2SB6zC5oywlnR0o1cglcrW96MD/uuCL/+tTczeB2C455ofs2mhpK7nKiA4FM
          +JZZ6XSBnq7sfsYD6knbvS//SXQV/qYb4bKMvwYnyMz63escgQhOsTT20ptc/w7f
          C+YPBR/rHImKspyIwxyqU8EXylFW8f3Ugi2+Fna3CAPR9yQIAChkCjUawUa2VFmm
          5KP8DHg6oWM5mdqcpvU5DMqpi8SA26DEFvULs8bR+kgDd5AU3I4+ei71GslOdfk4
          s1soKT4X2UK+dCCXui+/5ZJHakC67t5OgbMas3Hz4Q==
          =5TOS
          -----END PGP PUBLIC KEY BLOCK-----

  zabbix:
    - name: zabbix
    - humanname: Zabbix Official Repository - $basearch
    - baseurl: http://repo.zabbix.com/zabbix/3.4/rhel/7/$basearch/
    - enabled: 1
    - gpgcheck: 1
    - gpgkey: file:///etc/pki/rpm-gpg/RPM-GPG-KEY-ZABBIX-A14FE591
