#!/usr/bin/env python3

import os
import subprocess
import sys
import yaml

with open("/app/config.yaml", "r") as config_file:
  config = yaml.safe_load(config_file)

os.environ["CONFIG_USER"] = config["user"]["name"]
os.environ["CONFIG_PASSWORD"] = config["user"]["password"]
os.environ["CONFIG_RELEASE"] = config["debian"]["release"]
os.environ["CONFIG_PACKAGES_STANDARD"] = config["debian"]["packages"]["standard"]
os.environ["CONFIG_PACKAGES_DOWNLOAD_ONLY"] = config["debian"]["packages"]["download_only"]
os.environ["CONFIG_PACKAGES_BACKPORTS"] = config["debian"]["packages"]["backports"]
os.environ["CONFIG_COMMANDS_CHROOT"] = config["commands"]["chroot"]
os.environ["CONFIG_APT_SERVER_ADDRESS"] = config["debian"]["apt"]["server_address"]
os.environ["CONFIG_APT_LIST_BACKPORTS"] = config["debian"]["apt"]["lists"]["backports"]
os.environ["CONFIG_APT_LIST_EXTRAS"] = config["debian"]["apt"]["lists"]["extras"]
os.environ["CONFIG_APT_LIST_SECURITY"] = config["debian"]["apt"]["lists"]["security"]

subprocess.run("/app/scripts/_bootstrap_debian.sh", check=True, shell=True, stdout=sys.stdout, stderr=sys.stderr)
subprocess.run("/app/scripts/_customize_debian.sh", check=True, shell=True, stdout=sys.stdout, stderr=sys.stderr)
subprocess.run("/app/scripts/_build_iso.sh", check=True, shell=True, stdout=sys.stdout, stderr=sys.stderr)
