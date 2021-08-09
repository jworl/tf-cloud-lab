#!/usr/bin/env bash

# set hostname
sudo hostnamectl set-hostname ${name} &> /dev/null

echo "{\"interface\": \"${addr}\",\"timeout\": 15,\"loop_interval\": 30,\"cli_summary\": true,\"ping_on_rotate\": true,\"state_output\": \"changes\",\"auto_accept\": true,\"reactor\": [{\"salt/minion/*/start\": [\"/srv/salt/_reactors/bootstrap.sls\"]}]}" | sudo tee /tmp/master_conf &> /dev/null

echo "{\"id\": \"${name}\", \"master\": \"${addr}\", \"grains\": { \"owner\": \"CTUIR\", \"roles\": [ \"monarch\" ] }}" | sudo tee /tmp/minion_conf &> /dev/null

# point to self for name resolution
echo ${addr} salt | sudo tee -a /etc/hosts &> /dev/null

# sit tight while we wait for rsync
while ! [ -f /srv/salt/sysctl/init.sls ]; do
    sleep 2
done

# Download saltstack
sudo curl -fsSL https://bootstrap.saltproject.io -o install_salt.sh
sudo sh install_salt.sh -P -M -x python3 -J "`cat /tmp/master_conf`" -j "`cat /tmp/minion_conf`" &> /tmp/bootstrap.log

# build win repo
# probably a better method way but this works
sudo salt-run winrepo.update_git_repos | sudo tee ~/update_git_repos &> /dev/null
