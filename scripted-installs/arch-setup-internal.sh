#!/bin/bash

# This script will be run automatically by arch-setup-1.sh from within the
# arch-chroot for the new installation the script handles setting up
# default config for network manager, as well as creating a non-root user
# account and configuring a sudo group for that user so they can escalate
# privileges when need be.

# Link the timezone to the system localtime
ln -sf /usr/share/zoneinfo/US/Central /etc/localtime

# Installing packages for network, bootloader, basic text editor, and
# escalating privileges from a regular user account to a root account.
pacman --noconfirm -S networkmanager grub nano sudo

# Setting up hostname for local name resolution on the LAN
echo "arch-automatic-BIOS" >> /etc/hostname
systemctl enable NetworkManager.service

read -p "Enter your username (no spaces): " USER_TO_ADD
useradd -m $USER_TO_ADD

echo "Prompting for user password"
passwd $USER_TO_ADD

# Adding user to wheel group
gpasswd -a $USER_TO_ADD wheel

echo "
# Add by arch-setup-internal.sh script
%wheel ALL=(ALL) ALL

# Setting timeout for sudo password prompt to 30m
Defaults timestamp_timeout=30
" >> /etc/sudoers.d/wheel

# EDITOR=nano visudo

grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
exit
