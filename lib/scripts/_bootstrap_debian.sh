#!/usr/bin/env bash

set -e

rm -r "${HOME}/LIVE_BOOT/chroot"

debootstrap \
  --arch=amd64 \
  --variant=minbase \
  "${CONFIG_RELEASE}" \
  "${HOME}/LIVE_BOOT/chroot" \
  "http://${CONFIG_APT_SERVER_ADDRESS}/debian/"
