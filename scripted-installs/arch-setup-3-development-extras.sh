#!/bin/bash
pacman -S base-devel \
	code \
	jdk21-openjdk

flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
