#!/usr/bin/env bash

# set hostname
if command -v hostnamectl &> /dev/null; then
    sudo hostnamectl set-hostname ${name}
else
    sudo hostname ${name}
fi

# monarch name resolution
echo ${addr} salt | sudo tee -a /etc/hosts &> /dev/null

R=""
X="-x python3"
if $(cat /etc/*-release | grep "CentOS Linux 8 (Core)" &> /dev/null); then
    sudo yum -qy install python38
    pip3 install --user pyyaml
elif $(grep -E 'CPE_NAME="cpe:/o:amazon:linux:2018.03:ga"' /etc/*-release &> /dev/null); then
    R="-R 'archive.repo.saltproject.io'"
    X=""
fi

# sit tight while we wait for monarch
if command -v nc &> /dev/null; then
    while ! nc -z ${addr} 4506; do sleep 2; done
elif command -v python3 &> /dev/null; then
    while [ $(python3 -c "import socket; a = \"`echo -n ${addr}`\";sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM); sock.settimeout(2); print(\"True\") if 0 == sock.connect_ex((a,4506)) else False") != "True" ]; do sleep 2; done
elif command -v python &> /dev/null; then
    while [ $(python -c "import socket; a = \"`echo -n ${addr}`\";sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM); sock.settimeout(2); print(\"True\") if 0 == sock.connect_ex((a,4506)) else False") != "True" ]; do sleep 2; done
else
    while [ $(timeout 2 bash -c "</dev/tcp/${addr}/4506" 2> /dev/null && echo 0 || echo 1) -eq 1 ]; do sleep 2; done
    touch /tmp/lastresort
fi

# minion config file
echo "{\"id\": \"${name}\", \"master\": \"${addr}\", \"grains\": { \"owner\": \"CTUIR\", \"roles\": [ \"infantry\" ] }}" | sudo tee /tmp/minion_conf &> /dev/null

# Download saltstack
sudo curl -fsSL https://bootstrap.saltproject.io -o install_salt.sh
sudo sh install_salt.sh -P $X -j "`cat /tmp/minion_conf`" $R &> /dev/null
