#!/bin/bash
# This final script you can run to automatically setup the desktop environment.

# Install plasma desktop and sddm display manager
pacman --noconfirm -S plasma-meta sddm konsole

# Create configuration folder for the display manager
mkdir /etc/sddm.conf.d

echo "
Note enabling auto-login by entering a user here may cause some issues with
KWallet if the master password for KWallet and user password do not match.
"

read -p "Enter your \"regular\" username, once more (adding autologin config for that user, leave blank to skip): " USER_TO_ADD

# Write out a config file for autologin and setting plasma as the default DE
if [[ -n "$USER_TO_ADD" ]]; then
    echo "[Autologin]
    User=$USER_TO_ADD
    Session=plasma" > /etc/sddm.conf.d/autologin.conf
    # Necessary for auto-login to work?
    # systemctl set-default graphical.target
fi

# Enable the sddm service so it will run on next boot to handle graphical login
systemctl enable sddm.service

# Rebootsky! and should be ready to use the DE after this reboot
reboot
