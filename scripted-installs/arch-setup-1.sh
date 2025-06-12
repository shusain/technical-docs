#!/bin/bash

## !!!! WARNING !!!! this script will wipe out whatever partitions are setup on
## the primary disk when run.  Use at your own risk!

## This setup script meant to be run on a target virtual machine with one 32GB
## drive configured and ready to be setup.

# Define the countdown duration in seconds
countdown_seconds=10

echo "Press Ctrl+c now to cancel install, installation will wipe the primary drive."

# Loop while the countdown is greater than 0
while [ $countdown_seconds -gt 0 ]; do
  # Print the remaining time on the same line, overwriting previous output
  printf "Press Ctrl+c now to cancel or starting installation in... %2d\r" "$countdown_seconds"
  # Pause for 1 second
  sleep 1
  # Decrement the countdown
  ((countdown_seconds--))
done

# Writes out a file to use as scripted input to paritition the disk
# First 4GB is used for SWAP next 28GB is used for OS install
echo "label: dos
label-id: 0x9b071db8
device: /dev/sda
unit: sectors
sector-size: 512

/dev/sda1 : start=        2048, size=     8388608, type=82
/dev/sda2 : start=     8390656, size=    58718208, type=83" > /partition.dump

# Run the disk partitioning script to partition target device /dev/sda
sfdisk /dev/sda < /partition.dump

# print out time info (hopefully has synced with ntp by now)
timedatectl

# set hardware clock to the system clock
hwclock --systohc

# setup swap on partition 1 of primary device
mkswap /dev/sda1
swapon /dev/sda1

# Setup ext4 file-sytem on 2nd partition
mkfs.ext4 /dev/sda2

# Map the partition into the /mnt folder of the live system
mount /dev/sda2 /mnt

# Install base kernel+common kernel modules and arch system
pacstrap -K /mnt base linux linux-firmware

# Setup fstab file for automatic file-system mounts
genfstab -U /mnt >> /mnt/etc/fstab

# Custom for this setup script copy these arch-setup scripts into the
# installation in the root folder for ease of running the last script
# after reboot. For DE setup.
cp /arch-setup*.sh /mnt

# Runs the next script from within the chroot using /mnt as /
# When that script finishes it'll exit so this script can reboot the live system
arch-chroot /mnt /bin/bash -C /arch-setup-internal.sh
reboot
