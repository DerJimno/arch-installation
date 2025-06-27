#!/bin/bash


set -e


loadkeys us
ping google.com
timedatectl set-ntp true
timedatectl status

DEVICE="/dev/sda"

# Check before proceeding
echo "About to partition $DEVICE. THIS WILL ERASE DATA. Continue? (y/N)"
read -r confirm
if [[ "$confirm" != "y" ]]; then
  echo "Aborted."
  exit 1
fi

# Use fdisk in a here-document
fdisk "$DEVICE" <<EOF
g
n
1

+550M
n
2


t
1
1
w 
EOF


mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2
mount /dev/sda2 /mnt 

pacstrap /mnt base linux linux-firmware neovim sudo grub efibootmgr dosfstools os-prober mtools networkmanager git 
genfstab -U /mnt >> /mnt/etc/fstab
