#!/bin/bash


set -e


loadkeys us
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


cat > /mnt/chroot-part.sh <<'CHROOT'

#!/bin/bash


set -e


ln -sf /usr/share/zoneinfo/Africa/Algiers /etc/localtime

hwclock --systohc

# Locale
nvim -c 'g/^#\s*en_US.UTF/s/^#\s*//' -c 'wq' /etc/locale.gen
locale-gen

echo "computer" | tee /etc/hostname

tee /etc/hosts <<HOST
127.0.0.1   localhost
::1         localhost
127.0.1.1   computer.localdomain computer
HOST

echo "set up root password:"
passwd
useradd -m menaouer 
echo "set up user password:"
passwd menaouer

sed -i '0,/^# *%wheel/s/^# *//' /etc/sudoers

useradd -m -s /bin/bash -G wheel,audio,video,optical,storage,input,uinput menaouer

mkdir /boot/EFI
mount /dev/sda1 /boot/EFI
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable NetworkManager



CHROOT

chmod +x /mnt/chroot-part.sh
arch-chroot /mnt /chroot-part.sh

rm /mnt/chroot-part.sh
umount -l /mnt

reboot
