FROM ubuntu

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update \
    && apt-get install -y \
        debootstrap \
        dosfstools \
        squashfs-tools \
        xorriso \
        isolinux \
        syslinux-efi \
        grub-pc-bin \
        grub-efi-amd64-bin \
        mtools \
        rsync \
    && apt-get -q -y autoremove \
    && apt-get -q -y clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p $HOME/LIVE_BOOT

WORKDIR /root
