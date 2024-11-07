#!/usr/bin/env bash

set -e

IMG_FILE="steamlink-debian-$DEBIAN_VERSION-$KERNEL_VERSION.img"
dd if=/dev/zero of=$IMG_FILE bs=1M count=1024

# Use parted to create a partition table and a single primary partition
parted --script $IMG_FILE mklabel msdos        # Create an msdos partition table
parted --script $IMG_FILE mkpart primary ext3 1MiB 100%  # Create a primary partition

# Set up a loop device with partition mapping
LOOP_DEV=$(losetup --show -P -f $IMG_FILE)

# Format the first partition with ext3
mkfs.ext3 "${LOOP_DEV}p1"

# Mount the partition
mkdir /mnt/disk
mount steamlink-debian-$DEBIAN_VERSION-$KERNEL_VERSION.img /mnt/disk
tar -xpf rootfs.tar -C /mnt/disk/
umount -l steamlink-debian-$DEBIAN_VERSION-$KERNEL_VERSION.img

# Detach the loop device
losetup -d $LOOP_DEV

# Make the image file readable for non-root users
chmod a+r $IMG_FILE