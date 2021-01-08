#!/usr/bin/env bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${DIR}/lib/functions.bash

user=data
password=mypassword
proxy_address=bagend:3142
server_address=ftp.us.debian.org
release=buster

if [ -n "${proxy_address}" ];
then
    export http_proxy=${proxy_address}
fi

debootstrap \
    --arch=amd64 \
    --variant=minbase \
    ${release} \
    ${HOME}/LIVE_BOOT/chroot \
    http://${server_address}/debian/

# Files that we want deployed after bootstrap when the filesystem is established
# but before we start installing anything. Apt configs and any other base
# system files that wouldn't (or could safely) be ovewritten when installing
# apps below.
deploystaticfiles "static-pre"

chroot ${HOME}/LIVE_BOOT/chroot /bin/bash <<EOF
set -xe

export DEBIAN_FRONTEND=noninteractive

apt update

apt install -y --no-install-recommends \
    $(grep -vE "^\s*#" /root/config/packages.standard.list  | tr "\n" " ")

ln -s /usr/bin/python2 /usr/bin/python

apt install -y --no-install-recommends --download-only \
    $(grep -vE "^\s*#" /root/config/packages.download-only.list  | tr "\n" " ")

apt -t buster-backports install -y --no-install-recommends \
    $(grep -vE "^\s*#" /root/config/packages.backports.list  | tr "\n" " ")

useradd -m -s /bin/bash -G sudo ${user}
printf "${password}\n${password}\n" | passwd ${user}
passwd -l root
EOF

mkdir -p ${HOME}/LIVE_BOOT/chroot/home/${user}/.config/openbox
cat << EOF > ${HOME}/LIVE_BOOT/chroot/home/${user}/.config/openbox/autostart
xautolock -time 1 -locker "i3lock" &
EOF

# Files that should overwrite package maintainer versions.
deploystaticfiles "static-post"

chroot ${HOME}/LIVE_BOOT/chroot /bin/bash <<EOF
set -xe

systemctl enable custom-startup.service

update-initramfs -u
EOF

rm -f ${HOME}/LIVE_BOOT/chroot/etc/hosts

mkdir -p ${HOME}/LIVE_BOOT/{staging/{EFI/boot,boot/grub/x86_64-efi,isolinux,live},tmp}

mksquashfs \
    ${HOME}/LIVE_BOOT/chroot \
    ${HOME}/LIVE_BOOT/staging/live/filesystem.squashfs \
    -e boot

cp ${HOME}/LIVE_BOOT/chroot/boot/vmlinuz-* \
    ${HOME}/LIVE_BOOT/staging/live/vmlinuz && \
cp ${HOME}/LIVE_BOOT/chroot/boot/initrd.img-* \
    ${HOME}/LIVE_BOOT/staging/live/initrd

cat << EOF > ${HOME}/LIVE_BOOT/staging/isolinux/isolinux.cfg
UI vesamenu.c32

MENU TITLE Boot Menu
DEFAULT linux
TIMEOUT 50
MENU RESOLUTION 640 480
MENU COLOR border       30;44   #40ffffff #a0000000 std
MENU COLOR title        1;36;44 #9033ccff #a0000000 std
MENU COLOR sel          7;37;40 #e0ffffff #20ffffff all
MENU COLOR unsel        37;44   #50ffffff #a0000000 std
MENU COLOR help         37;40   #c0ffffff #a0000000 std
MENU COLOR timeout_msg  37;40   #80ffffff #00000000 std
MENU COLOR timeout      1;37;40 #c0ffffff #00000000 std
MENU COLOR msg07        37;40   #90ffffff #a0000000 std
MENU COLOR tabmsg       31;40   #30ffffff #00000000 std

LABEL linux
  MENU LABEL Debian Live [BIOS/ISOLINUX]
  MENU DEFAULT
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd boot=live net.ifnames=0

LABEL linux
  MENU LABEL Debian Live [BIOS/ISOLINUX] (nomodeset)
  MENU DEFAULT
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd boot=live nomodeset net.ifnames=0
EOF

cat <<'EOF' >${HOME}/LIVE_BOOT/staging/boot/grub/grub.cfg
search --set=root --file /DEBIAN_CUSTOM

set default="0"
set timeout=5

# If X has issues finding screens, experiment with/without nomodeset.

menuentry "Debian Live [EFI/GRUB]" {
    linux ($root)/live/vmlinuz boot=live net.ifnames=0
    initrd ($root)/live/initrd
}

menuentry "Debian Live [EFI/GRUB] (nomodeset)" {
    linux ($root)/live/vmlinuz boot=live nomodeset net.ifnames=0
    initrd ($root)/live/initrd
}
EOF

cat <<'EOF' >${HOME}/LIVE_BOOT/tmp/grub-standalone.cfg
search --set=root --file /DEBIAN_CUSTOM
set prefix=($root)/boot/grub/
configfile /boot/grub/grub.cfg
EOF

touch ${HOME}/LIVE_BOOT/staging/DEBIAN_CUSTOM

cp /usr/lib/ISOLINUX/isolinux.bin "${HOME}/LIVE_BOOT/staging/isolinux/" && \
cp /usr/lib/syslinux/modules/bios/* "${HOME}/LIVE_BOOT/staging/isolinux/"

cp -r /usr/lib/grub/x86_64-efi/* "${HOME}/LIVE_BOOT/staging/boot/grub/x86_64-efi/"

grub-mkstandalone \
    --format=x86_64-efi \
    --output=${HOME}/LIVE_BOOT/tmp/bootx64.efi \
    --locales="" \
    --fonts="" \
    "boot/grub/grub.cfg=${HOME}/LIVE_BOOT/tmp/grub-standalone.cfg"

(cd ${HOME}/LIVE_BOOT/staging/EFI/boot && \
    dd if=/dev/zero of=efiboot.img bs=1M count=20 && \
    mkfs.vfat efiboot.img && \
    mmd -i efiboot.img efi efi/boot && \
    mcopy -vi efiboot.img ${HOME}/LIVE_BOOT/tmp/bootx64.efi ::efi/boot/
)

xorriso \
    -as mkisofs \
    -iso-level 3 \
    -o "${HOME}/LIVE_BOOT/debian-custom.iso" \
    -full-iso9660-filenames \
    -volid "DEBIAN_CUSTOM" \
    -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
    -eltorito-boot \
        isolinux/isolinux.bin \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        --eltorito-catalog isolinux/isolinux.cat \
    -eltorito-alt-boot \
        -e /EFI/boot/efiboot.img \
        -no-emul-boot \
        -isohybrid-gpt-basdat \
    -append_partition 2 0xef ${HOME}/LIVE_BOOT/staging/EFI/boot/efiboot.img \
    "${HOME}/LIVE_BOOT/staging"

cp ${HOME}/LIVE_BOOT/debian-custom.iso /output/
