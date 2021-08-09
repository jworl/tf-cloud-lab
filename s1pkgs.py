#! /usr/bin/env python3

'''
author: Joshua Worley

requires a json file containing API Key!
the path to this file should be specified in
arguement -t

expected format of JSON file:
{
    "Content-Type": "application/json",
    "Authorization": "ApiToken yOUrt0K3nH3rE"
}

Be wise: chmod 400 your json file.

'''

import argparse
import hashlib
import json
import pprint
import re
import requests
import yaml

from datetime import datetime
from os import makedirs
from os import path
from os import rename

def sha1(F):
    hashit = hashlib.sha1()
    with open(F, 'rb') as f:
        b = f.read()
        hashit.update(b)
    return hashit.hexdigest()

time = datetime.utcnow().isoformat()

parser = argparse.ArgumentParser(description='S1 package retrieval')
parser.add_argument('-t', action='store', required=True,
                    dest='TOKEN', help='path to API Token')
parser.add_argument('-c', action='store', required=True,
                    dest='CONSOLE', help='S1 Console')
parser.add_argument('-s', action='store', required=True,
                    dest='SITEID', help='S1 Site ID')

P = parser.parse_args()
pp = pprint.PrettyPrinter(indent=1)

# Directory for downloaded files
fp = "salt/files/s1/"

# File path for S1 site data
sp = "pillar/common/sentinelone.sls"

# Create directory where files will
# be downloaded if it doesn't exist
if not path.isdir(fp):
    makedirs(fp)

with open(P.TOKEN) as f:
    HEADERS = json.load(f)

if "Content-Type" not in HEADERS:
    print("[&] Missing Content-Type key")
    exit(2)
elif "Authorization" not in HEADERS:
    print("[&] Missing Authorization key")
    exit(2)
elif not re.match("^ApiToken ", HEADERS['Authorization']):
    print("[&] Invalid format of Authorization value")
    exit(2)

console = P.CONSOLE
get_site = "web/api/v2.1/sites/{}".format(P.SITEID)
get_pkgs = "web/api/v2.1/update/agent/packages"

PAYLOAD = {
    "packageType": "Agent",
    "siteIds": P.SITEID,
    "sortOrder": "desc",
    "query": "GA"
}

print("[i] S1 console: {}".format(console))
print("[i] SiteID: {}".format(P.SITEID))

r = requests.get(
    "{}/{}".format(console, get_site),
    headers=HEADERS,
    params=PAYLOAD
)

if r.status_code == 403:
    print(r.content)
    print("[&] Forbidden! Invalid token? On the VPN?")
    exit(2)

site_data = r.json()
print(type(site_data))
pp.pprint(site_data)

pillar_data = [
    "accountId", "creatorId", "id", "name",
    "registrationToken", "state", "suite"
]

site_pillar = {
    "sentinelone": {}
}

for entry in pillar_data:
    site_pillar["sentinelone"].update(
        {entry:site_data['data'][entry]}
    )

site_pillar["sentinelone"].update({"console":P.CONSOLE})

with open(sp, 'w') as f:
    f.write(yaml.dump(site_pillar))

RESPONSE = []

while True:
    r = requests.get(
        "{}/{}".format(console, get_pkgs),
        headers=HEADERS,
        params=PAYLOAD
    )

    RESPONSE.extend(r.json()['data'])
    if r.json()['pagination']['nextCursor'] is None:
        break

    PAYLOAD.update({
        "cursor":r.json()['pagination']['nextCursor']
    })

# pkgs_json_fn = "s1pkgs-{}_{}.json".format(P.SITEID, time)
# with open(pkgs_json_fn, 'w') as f:
#     json.dump(RESPONSE, f)

# organize various versions
'''
V = {
    $osType: {
        $fileExtension: {
            "version": $version: {
                "filename": $fileName
                "link": $link,
                "sha1": $sha1,
                "osArch": $osArch
            }
        }
    }
}
'''
V = {}
E = [
    "fileName", "link", "sha1", "osArch",
    "osType", "status", "version"
]
for c in RESPONSE:
    if c["osArch"] == "32 bit":
        continue
    if c["platformType"] not in V:
        V[c["platformType"]]= {}
    if c["fileExtension"] not in V[c["platformType"]]:
        V[c["osType"]][c["fileExtension"]] = {}
    if c["version"] not in V[c["platformType"]][c["fileExtension"]]:
        V[c["platformType"]][c["fileExtension"]][c["version"]] = {}
    for e in E:
        V[c["platformType"]][c["fileExtension"]][c["version"]][e] = c[e]

# select newest version for each file extension
for k in V.copy():
    for e in V[k]:
        U = V[k][e][sorted(V[k][e].keys())[-1]]
        if k == "linux" and e == ".rpm":
            candidate = "rhel"
        elif k == "linux" and e == ".deb":
            candidate = "debian"
        elif k == "macos" and e == ".pkg":
            candidate = "macos"
        elif k == "windows" and e == ".exe":
            candidate = "windows"
        else:
            print("Unsupported: {}".format(U['fileName']))
            continue
        print("[i] {} Latest GA release for {}".format(U['fileName'], k))
        fn = "s1_{}_latest{}".format(candidate, e)
        full = "{}{}".format(fp, fn)
        if path.exists(full):
            print("[!] {} candidate exists. Checking for a match.".format(fn))
            existing = sha1(full)
            if existing == U['sha1']:
                print("[!] {} has not changed, skipping".format(fn))
                continue
            else:
                found = False
                archives = "{}archives/".format(fp)
                if not path.isdir(archives):
                    makedirs(archives)
                for lookfor in RESPONSE:
                    if existing == lookfor['sha1']:
                        print("[i] Found match {}".format(lookfor['fileName']))
                        rename(full, "{}{}".format(archives, lookfor['fileName']))
                        found = True
                        break
                if found is False:
                    print("[!] Could not find an old match; using today's date and time UTC")
                    rename(full, "{}{}_{}{}".format(archives, k, time, e))

        print("[i] {} downloading...".format(fn))
        r = requests.get(U['link'], headers=HEADERS)
        with open(full, 'wb') as f:
            f.write(r.content)
