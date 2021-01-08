#!/bin/bash

set -xe

d() {
    printf "%02X" $(shuf -i 0-255 -n 1)
}

mac="00:$(d):$(d):$(d):$(d):$(d)"

printf "[start]: ${1}\n"
printf "setting ${1} mac to ${mac}\n"
/usr/bin/ip addr
/usr/bin/ip link set dev $1 down
/usr/bin/ip link set dev $1 address ${mac}
/usr/bin/ip link set dev $1 up
/usr/bin/ip addr
printf "[end]: ${1}\n"
