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
    python3 python3-venv \
  && apt-get -q -y autoremove \
  && apt-get -q -y clean \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV VIRTUAL_ENV=/env
ENV PATH="${VIRTUAL_ENV}/bin:$PATH"
RUN python3 -m venv ${VIRTUAL_ENV}
COPY ./poetry.lock /env/
COPY ./pyproject.toml /env/
RUN pip install poetry && cd /env && poetry install
