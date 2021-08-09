#!/usr/bin/env bash
# manual rsync
# can be used for pushing salt and pillar
# data during development

if [ ! -f terraform.tfstate ]; then
    echo "[&] Missing terraform.tfstate"
    exit 2
fi

perpetua=$(jq -r '.resources[] | select(.type=="aws_eip") | .instances[] | select(.index_key=="perpetua") | .attributes.public_ip' terraform.tfstate)

echo "[i] perpetua: ${perpetua}"
for A in pillar salt; do
    echo "[i] syncing ${A}"
    rsync -urpv --delete --exclude={salt/files/s1/archives,salt/files/dummy,salt/win} --rsync-path="sudo rsync" -e "ssh -o StrictHostKeyChecking=no -i ~/.ssh/aws-key" $A ubuntu@${perpetua}:/srv
done
