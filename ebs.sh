#!/bin/bash

yum update -y
yum upgrade -y

lsblk
echo "enter block device: "
read BLOCK

file -s /dev/$BLOCK
mkfs -t ext4 /dev/$BLOCK

echo "enter location to mount directory"
read MOUNT
echo "mkdir $MOUNT"

mount /dev/$BLOCK $MOUNT 

cp /etc/fstab /etc/fstab.orig

fstabEntry="/dev/$BLOCK $MOUNT ext4 defaults,noatime 0 2"
echo $fstabEntry >> /etc/fstab
mount -a
