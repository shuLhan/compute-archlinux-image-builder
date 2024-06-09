#!/bin/sh

image=$1
echo $image
qemu-system-x86_64 -enable-kvm \
	-drive format=raw,file=$image,if=virtio \
	-device virtio-net,netdev=network0 \
	-netdev user,id=network0 \
	-m 512M \
	-bios /usr/share/ovmf/x64/OVMF.fd \
	-boot menu=on
