#!/bin/bash

# Installs packages for working in C/C++, Java, Python, etc. (compilers/interpreters/debuggers etc.)

# Sets up vs-codium open source version of code and the extra marketplace bits for the proprietary extensions store.

if [ "$EUID" == 0 ]; then
	echo "Run this script as your regular user the script may prompt for a sudo password to complete installations."
	exit -1
fi

echo "Script may prompt for sudo password for package installations."


sudo pacman -S base-devel \
	code \
	jdk21-openjdk \
	git

flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo


# https://aur.archlinux.org/packages/code-marketplace

# Create location for source and download
mkdir ~/AUR/
git clone https://aur.archlinux.org/code-marketplace.git ~/AUR/code-marketplace
cd ~/AUR/code-marketplace

# Build the package from source and then install the built package
makepkg
sudo pacman -U code-marketplace*.zst
