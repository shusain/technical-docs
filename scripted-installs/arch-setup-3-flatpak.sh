#!/bin/bash
echo "Script may prompt for sudo password for package installations."

sudo pacman -S flatpak \
	xdg-desktop-portal \
	xdg-desktop-portal-kde \
	flatpak-kcm

flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo "To search packages  [flatpak search somepackage]"
echo "To install packages [flatpak intall somepackage]"
echo "To remove packages  [flatpak remove somepackage]"
