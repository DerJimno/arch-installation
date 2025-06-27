#!/bin/bash

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

pacstrap /mnt base linux llinux-firmware neovim sudo grub efibootmgr dosfstools os-prober mtools networkmanager git 

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Africa/Algiers /etc/localtime

hwclock --systohc

# Locale
nvim -c 'g/^#\s*en_US.UTF/s/^#\s*//' -c 'wq' /etc/locale.gen
locale-gen

echo "pc-box" | tee /etc/hostname
echo "127.0.1.1	pc-box.localdomain pc-box" | /etc/hosts

passwd
useradd -m jimno 
passwd jimno

EDITOR='nvim +":g/^#\s*%wheel\s\+ALL/s/^#\s*//" +wq' visudo
 
sudo groupadd uinput
usermod -aG wheel,audio,video,optical,storage,input,uinput jimno

mkdir /boot/EFI
mount /dev/sda1 /boot/EFI
grub-install --target=x86_64-efi  --bootloader-id=grub_uefi --recheck
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable NetworkManager


exit 
umount -l /mnt
