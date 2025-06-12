#!/bin/bash

echo "
This script will copy the remaining scripts to the new machine to be configured
and start the installation process.
"

read -p "Enter the target machine IP Address: " TARGET_MACHINE_IP

echo "connecting to target machine, run /arch-setup-1.sh to begin the install"

scp arch*.sh root@$TARGET_MACHINE_IP:/
ssh root@$TARGET_MACHINE_IP
