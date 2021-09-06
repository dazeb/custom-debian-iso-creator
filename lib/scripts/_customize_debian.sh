#!/usr/bin/env bash

set -e

printf "${CONFIG_APT_LIST_BACKPORTS}" > "${HOME}/LIVE_BOOT/chroot/etc/apt/sources.list.d/backports.list"
printf "${CONFIG_APT_LIST_EXTRAS}" > "${HOME}/LIVE_BOOT/chroot/etc/apt/sources.list.d/extras.list"
printf "${CONFIG_APT_LIST_SECURITY}" > "${HOME}/LIVE_BOOT/chroot/etc/apt/sources.list.d/security.list"

# Copy basic configuration files that these scripts will always need.
rsync -avr /app/standard-files/ "${HOME}/LIVE_BOOT/chroot/"
# Copy any additional system-files the user has defined.
rsync -avr /app/custom-system-files/ "${HOME}/LIVE_BOOT/chroot/"

chroot ${HOME}/LIVE_BOOT/chroot /bin/bash <<EOF
set -e

export DEBIAN_FRONTEND=noninteractive

apt update

# Install packages, but use DPkg options to preserve any custom configs.
# https://debian-handbook.info/browse/stable/sect.package-meta-information.html#sidebar.questions-conffiles
apt install -y --no-install-recommends -o DPkg::options::="--force-confdef" -o DPkg::options::="--force-confold" ${CONFIG_PACKAGES_STANDARD}
apt install -y --no-install-recommends -o DPkg::options::="--force-confdef" -o DPkg::options::="--force-confold" --download-only ${CONFIG_PACKAGES_DOWNLOAD_ONLY}
apt -t buster-backports install -y --no-install-recommends -o DPkg::options::="--force-confdef" -o DPkg::options::="--force-confold" ${CONFIG_PACKAGES_BACKPORTS}

useradd -m -s /bin/bash -G sudo ${CONFIG_USER}
printf "${CONFIG_PASSWORD}\n${CONFIG_PASSWORD}\n" | passwd ${CONFIG_USER}
passwd -l root
EOF

# Copy additional files as needed to further customize the image.
uid=$(chroot ${HOME}/LIVE_BOOT/chroot /bin/bash -c "id -u ${CONFIG_USER}")
gid=$(chroot ${HOME}/LIVE_BOOT/chroot /bin/bash -c "id -g ${CONFIG_USER}")
rsync -avr --chown "${uid}:${gid}" /app/custom-user-files/ "${HOME}/LIVE_BOOT/chroot/"

chroot "${HOME}/LIVE_BOOT/chroot" /bin/bash -c "${CONFIG_COMMANDS_CHROOT}"

chroot "${HOME}/LIVE_BOOT/chroot" /bin/bash <<EOF
systemctl enable custom-startup.service

update-initramfs -u
EOF

rm -f "${HOME}/LIVE_BOOT/chroot/etc/hosts"
