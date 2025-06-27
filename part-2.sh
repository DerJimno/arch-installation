#!/bin/bash


set -e


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
