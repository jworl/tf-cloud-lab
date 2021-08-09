#!/usr/bin/env python3

import argparse
import boto3
import yaml

from botocore.exceptions import ClientError
from os import makedirs
from os import path
from re import search

def get_obj(s, KEY, local_file):
    try:
        print("[+] downloading {}".format(KEY))
        s.download_file(KEY, local_file)
    except botocore.exceptions.ClientError as e:
        if e.response['Error']['Code'] == "404":
            print("The object does not exist.")
        else:
            raise

parser = argparse.ArgumentParser(description='S1 package retrieval')
parser.add_argument('-p', action='store', required=True, dest='PN', help='AWS profile')
parser.add_argument('-b', action='store', required=True, dest='BUCKET', help='AWS S3 Bucket Name')
parser.add_argument('-c', action='store', required=True, dest='COMPANY_CODE', help='Company Code')
parser.add_argument('-g', action='store', required=True, dest='GROUP_NAME', help='Group Name')
parser.add_argument('-e', action='store', required=True, dest='EMAIL', help='User E-mail')

P = parser.parse_args()

fp = "salt/files/cbth/"
sp = "pillar/common/carbonblack.sls"

if not path.isdir(fp):
    print("[+] creating {}".format(fp))
    makedirs(fp)
else:
    print("[i] {} exists".format(fp))

S = boto3.Session(profile_name=P.PN)
s3r = S.resource('s3')
BO = s3r.Bucket(P.BUCKET)
contents = [_.key for _ in BO.objects.all() if not search('/$', _.key)]

pillar = {
    'carbonblack':{
        'company_code': P.COMPANY_CODE,
        'group_name': P.GROUP_NAME,
        'user_email': P.EMAIL
    }
}

for c in contents:
    C = c.split('/')
    pillar['carbonblack'][C[0]] = C[1]

print("[+] writing pillar data: {}".format(sp))
with open(sp, 'w') as f:
    f.write(yaml.dump(pillar))

for key in contents:
    FP = "{}{}".format(fp, key.split('/')[1])
    if path.exists(FP):
        print("[i] {} exists".format(FP))
    else:
        get_obj(BO, key, FP)
