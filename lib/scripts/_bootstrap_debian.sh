#!/usr/bin/env bash

set -e

rm -rf "${HOME}/LIVE_BOOT/chroot"

cache_server=""
if [ -n "${CONFIG_APT_CACHE_SERVER_ADDRESS}" ];
then
  cache_server="${CONFIG_APT_CACHE_SERVER_ADDRESS}/"
fi

debootstrap \
  --arch=amd64 \
  --variant=minbase \
  "${CONFIG_RELEASE}" \
  "${HOME}/LIVE_BOOT/chroot" \
  "http://${cache_server}${CONFIG_APT_SERVER_ADDRESS}/debian/"

if [ -n "${cache_server}" ];
then
  sed -i "s|${cache_server}||g" ${HOME}/LIVE_BOOT/chroot/etc/apt/*.list
fi
