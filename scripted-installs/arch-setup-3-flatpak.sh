#!/bin/bash
pacman -S flatpak \
	xdg-desktop-portal \
	xdg-desktop-portal-kde \
	flatpak-kcm

flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
