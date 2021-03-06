#!/usr/bin/env bash

# author: Joshua Worley
# contact: joshua.worley@warnermedia.com

help() {
    echo ${0##*/} usage
    echo "-k, --key     : path private key for decrypting passphrase"
    echo "-t, --tfstate : path to terraform.tfstate file"
    exit 2
}

DECRYPT() {
    grep "Proc-Type: 4,ENCRYPTED" ${1} &> /dev/null
    if [[ $? -eq 0 ]]; then
        echo -n "Enter passphrase for key ${1}: "
        read -s X ; echo
    else
        X=""
    fi

    for a in $(seq 0 `echo $2 | jq length-1`); do
        ID=$(echo $2 | jq -r ".[$a] | .id")
        NM=$(echo $2 | jq -r ".[$a] | .tags.Name")
        PI=$(echo $2 | jq -r ".[$a] | .public_ip")
        PE=$(echo $2 | jq -r ".[$a] | .password_data")
        if [[ $PE != "" ]]; then
            echo $PE | base64 -d > ${host}.bin
            PD=$(openssl rsautl -decrypt -passin pass:${X} -inkey ${1} -in ${host}.bin)
            rm -f ${host}.bin
        else
            PD="no passphrase, use private key"
        fi
        I="{\"id\":\"$ID\", \"name\":\"$NM\", \"public_ip\":\"$PI\", \"password_data\":\"$PD\"}"
        echo $I | jq .
    done

    I=$(echo $(head -128 /dev/urandom | strings | tail -n1000))
    X=$(echo $(head -128 /dev/urandom | strings | tail -n1000))
}

if [[ $# -eq 0 ]]; then help; fi

TFSTATE="terraform.tfstate"

while (( "$#" )); do
    case $1 in
        -k|--key)
            if [ -z ${2} ]; then
                help
            elif [ ! -f ${2} ]; then
                echo "[!] did not find key ${2}"
                echo; help
            else
                KEY=$2
            fi
            shift
        ;;
        -t|--tfstate)
            if [ -z ${2} ]; then
                help
            elif [ -f ${2} ]; then
                echo "[!] did not find terraform.tfstate file."
                echo "[!] is this script in the same directory?"
                echo "[!] did you provide a valid path?"
                echo; help
            else
                TFSTATE=$2
            fi
            shift
        ;;
        *)
            help
        ;;
    esac
    shift
done

if [[ $(jq '.resources | length' ${TFSTATE}) -eq 0 ]]; then
    echo "[!] ${TFSTATE} has 0 resources"
    exit 2
else
    DATA=$(jq '[.resources[] | select(.type=="aws_instance") | .instances[].attributes]' ${TFSTATE})
fi

DECRYPT $KEY "$DATA"
