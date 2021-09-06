#!/bin/bash

set -e

date

id=$(cat /etc/machine-id)
name=$(printf "${id}" | head -c8)
hostnamectl set-hostname "${name}"

cat << EO1 > /etc/hosts
127.0.0.1   ${name} ${name}.localhost localhost
::1         ${name} localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
EO1

date
