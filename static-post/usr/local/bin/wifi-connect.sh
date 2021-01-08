#!/usr/bin/env bash

set -xe

nmcli dev wifi connect "${1}" password "${2}"
