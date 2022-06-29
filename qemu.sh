#!/bin/sh

image=$1
echo $image
qemu-system-x86_64 -enable-kvm \
	-drive format=raw,file=$image,if=virtio \
	-net none \
	-m 512M \
	-bios /usr/share/ovmf/x64/OVMF.fd \
	-boot menu=on
