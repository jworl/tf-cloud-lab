#!/usr/bin/env python3

import string
import random
import yaml

pf = "pillar/common/victims.sls"

with open('victims.yml', 'r') as f:
    victims = yaml.full_load(f)

for v in victims.copy():
    values = string.ascii_letters + string.digits + string.punctuation
    password = ''.join(random.choice(values) for i in range(15))
    victims[v].update({"password":password})

PILLAR = {
    "victims": victims
}

with open(pf, 'w') as f:
    yaml.dump(PILLAR, f)
