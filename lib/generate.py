#!/usr/bin/env python3

import os
import subprocess
import sys
import yaml

with open("/app/config.yaml", "r") as config_file:
  config = yaml.safe_load(config_file)

user = config.get("user", {})
debian = config.get("debian", {})
debian_apt = debian.get("apt", {})
debian_apt_lists = debian_apt.get("lists", {})
debian_apt_packages = debian_apt.get("packages", {})
commands = config.get("commands", {})

# Required config settings.
os.environ["CONFIG_USER"] = user.get("name")
os.environ["CONFIG_PASSWORD"] = user.get("password")
os.environ["CONFIG_RELEASE"] = debian.get("release")
os.environ["CONFIG_APT_SERVER_ADDRESS"] = debian_apt.get("server_address")

# Optional config settings.
os.environ["CONFIG_PACKAGES_STANDARD"] = debian_apt_packages.get("standard", "")
os.environ["CONFIG_PACKAGES_BACKPORTS"] = debian_apt_packages.get("backports", "")
os.environ["CONFIG_PACKAGES_DOWNLOAD_ONLY"] = debian_apt_packages.get("download_only", "")
os.environ["CONFIG_COMMANDS_CHROOT"] = commands.get("chroot", "")
os.environ["CONFIG_APT_CACHE_SERVER_ADDRESS"] = debian_apt.get("bootstrap_cache_server_address", "")
os.environ["CONFIG_APT_LIST_BACKPORTS"] = debian_apt_lists.get("backports", "")
os.environ["CONFIG_APT_LIST_EXTRAS"] = debian_apt_lists.get("extras", "")
os.environ["CONFIG_APT_LIST_SECURITY"] = debian_apt_lists.get("security", "")

subprocess.run("/app/scripts/_bootstrap_debian.sh", check=True, shell=True, stdout=sys.stdout, stderr=sys.stderr)
subprocess.run("/app/scripts/_customize_debian.sh", check=True, shell=True, stdout=sys.stdout, stderr=sys.stderr)
subprocess.run("/app/scripts/_build_iso.sh", check=True, shell=True, stdout=sys.stdout, stderr=sys.stderr)
