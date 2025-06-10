#!/bin/bash
# This final script you can run to automatically setup the desktop environment.

# Install plasma desktop and sddm display manager
pacman --noconfirm -S plasma-meta sddm konsole

# Create configuration folder for the display manager
mkdir /etc/sddm.conf.d

read -p "Enter your \"regular\" username, once more: " USER_TO_ADD
# Write out a config file for autologin and setting plasma as the default DE
echo "[Autologin]
User=$USER_TO_ADD
Session=plasma" > /etc/sddm.conf.d/autologin.conf

# Tell systemd to start using the GUI on boot instead of a text login
systemctl set-default graphical.target

# Enable the sddm service so it will run on next boot to handle graphical login
systemctl enable sddm.service

# Rebootsky! and should be ready to use the DE
reboot
