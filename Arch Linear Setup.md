## Prerequisites
- [Download](https://archlinux.org/download/) and flash onto USB and boot or otherwise boot the ISO
- Hit enter to load default boot option for live environment

Once the system finishes booting you'll be given a root shell to configure the disks and install and configure packages to complete the installation.

Any text in `code-blocks` is a terminal command.

Since some commands will be user or system specific those variables will be setup as first line in sets of commands that share the variable.  Make sure to update those variable values to match your specific user or system.

## Setup Keyboard and/or Locale
List Keyboard maps (default is US).  It is important the keymap is correct so commands and passwords typed in are stored correctly.
```bash
localectl list-keymaps
```
_Change to a different keymap (German example)_ `loadkeys de-latin1`

## Set system default locale
Set the default language to english and character encoding to UTF8: `echo "LANG=en_US.UTF-8" > /etc/locale.conf`
run `locale-gen` to create a /etc/local.gen file then edit the file un-comment your locale and then run `locale-gen` again to apply the given locale.
### Generate Locales (if needed)
For more details on generating and setting up different locales for proper language and conversion/formatting rules for your region see [the arch wiki](https://wiki.archlinux.org/title/Locale#LANG:_default_locale).

### Adjust console fonts (if needed)
- Show all console fonts `ls /usr/share/kbd/consolefonts/`
- Set a HiDPI font
`setfont ter-132b`

## Live System Network Connection
| Command | Description |
|-------- | ----------  |
|`ip link`| Show network interface info, look for eth0 or wlan0
|`ping -c 10 archlinux.org`| Ping well known URL 10 times to make sure dns/routing is able to resolve the server (Ctrl+C to quit)
|`timedatectl`| Check system time has been updated with network based time (UTC)
|`hwclock --systohc`| Sets hardware clock from system clock (which should be matching ntp/network based time now)

## Disk Partitioning
- List all current disks and their partitions `fdisk -l`
- Assuming **/dev/sda** is the device/drive we want to edit the partitions on type: `fdisk /dev/sda`
- The partitioning below assumes the most basic setup with BIOS instead of UEFI and only a separate swap and shared boot/system partition

> Within fdisk any changes won't persist until `w` is entered to write the partitions to the disk.

### In `fdisk` console
First we'll create the swap partition:

- `m` see help message of commands
- create a new partition `n`
    - primary partition for swap space `p`
    - hit enter to accept starting position
    - for end position enter a size for the partition `+4G`

Next make a partition for the bootloader and OS:
- new partition again `n`
    - primary partition `p`
      > Accept all defaults by hitting enter

- back at fdisk main console change partition type `t`
- choose partition one `1` 
- change to swap `swap`

- back at fdisk main console print layout `p`

- If everything looks good enough w to write it out and forever hold your peace
write partition tables to disk `w`


### Initialize/format partitions and setup swap
| Command                | Description                                                  |
| ---------------------- | ------------------------------------------------------------ |
| `mkswap /dev/sda1`     | Prepare the partition as swap space                          |
| `swapon /dev/sda1`     | Allow kernel to use the swap partition                       |
| `mkfs.ext4 /dev/sda2`  | Format primary bootloader/OS partition using ext4 filesystem |
| `mount /dev/sda2 /mnt` | Mount the OS partition into /mnt                             |
For UEFI setup a separate.

## Installing Packages
Optionally edit mirrors list `nano /etc/pacman.d/mirrorlist` to choose mirrors closer to your region for packages.

Gets arch base package, Linux kernel, and [common kernel modules](https://gitlab.com/kernel-firmware/linux-firmware) for hardware support
```bash
pacstrap -K /mnt base linux linux-firmware
```
The command above may take a bit to download and extract all the core packages for the system onto disk.

Generate file-system fstab file for auto mount of the partitions we just created, using partition UUIDs to map to mount points.
```
genfstab -U /mnt >> /mnt/etc/fstab
```
Can check the generated file `cat /mnt/etc/fstab`

Once the base system is done installing we can use chroot which will effectively change `/` in our shell to be `/mnt` from the OS partition we just created.  After we chroot any packages we install with `pacman` or other system commands will be run/saved onto the filesystem on disk.

| Command                                                | Description                                                                           |
| ------------------------------------------------------ | ------------------------------------------------------------------------------------- |
| `arch-chroot /mnt`                                     | Change root to be /mnt for installing on the new partition                            |
| `ln -sf /usr/share/zoneinfo/US/Central /etc/localtime` | Link timezone info for local time.<br/>Note choose appropriate region US/Central here |
| `date`                                                 | should show the correct local time.                                                   |

### Install some common basic dependencies
```bash
pacman -S networkmanager grub nano sudo
```
Network manager as the name implies handles network connections to obtain an IP from a DHCP router/server and configure the network connections.  It includes the `NetworkManager.service` and `nmcli` we'll use soon to enable networking on the installed OS (the live OS will have started the networking services on your behalf).

GRUB will be our bootloader and handle loading the initramfs and kernel that will handle loading the rest of the services.

Nano is a simple text editor for editing any config files, most services in the system have system level configuration in the `/etc/` folder.  When editing with nano arrow keys can be used to navigate, some useful hot keys are listed at the bottom of the app, some noteable mentions for basic usability listed below.

#### Nano Hotkeys
- `Ctrl+o` - Write-out/save file. Enter to confirm location.
- `Ctrl+w` - Search for where string is. Type search term hit enter.
- `Ctrl+x` - Exit. If file was changed since save will prompt for save and where to write the file.

### Set the system name
```bash
# Write the network/system "host name" it will broadcast on local network
# can be anyname up to 64 characters, no spaces use dot as delimiter
echo "archbtw" >> /etc/hostname
```

Turn on Network manager and enable service on startup
`systemctl enable NetworkManager.service`

## User Setup and Group

### Create a root user password
`passwd`

### Setup a non-root User
```bash
# Change the value
USER_TO_ADD=shaun

useradd -m $USER_TO_ADD
passwd $USER_TO_ADD

# Create sudo group
groupadd sudo

# Add user we just made to the group we just made
gpasswd -a $USER_TO_ADD sudo

# Open sudoers file with visudo, once done just save/exit, see below
EDITOR=nano visudo     
```

To allow users in sudo group to use sudo to escalate to root temporarily, add or un-comment the line with: `%sudo ALL=(ALL:ALL) ALL`
To extend the timeout between password requests (30m for example) for sudo add: `Defaults timestamp_timeout=30`
## Install Grub Boot-loader
```bash
grub-install --target=x86_64 /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
```

## KDE-Plasma Desktop Environment
Install plasma-meta package: `pacman -S plasma-meta`
Run plasma manually verify the plasma install is working: `/usr/lib/plasma-dbus-run-session-if-needed /usr/bin/startplasma-wayland`
### Setup/configure SDDM
Logout of plasma desktop to return back to the terminal to setup SDDM.  To auto start plasma we'll need a display manager ideally SDDM is recommended for plasma.

```bash
pacman -S sddm
mkdir /etc/sddm.conf.d

echo "[Autologin]
User=shaun
Session=plasma" > /etc/sddm.conf.d/autologin.conf

systemctl set-default graphical.target
systemctl enable sddm.service
```
### Install Optional Packages
Extra packages can be installed using `pacman -S packagenamehere`

```bash
pacman -S\
	konsole\
	dolphin\
	konqueror\
	yakuake\
	gdu\
	fastfetch\
	man\
	base-devel\
	code\
	git
```

The AUR can be used for building packages from source as well for example adding code-marketplace for getting extensions from the proprietary MS store in the code-oss IDE installed above

```
mkdir aur
cd aur
git clone https://aur.archlinux.org/code-marketplace.git
cd code-marketplace/
makepkg
pacman -U code-marketplace-1.100.2-1-any.pkg.tar.zst
```

Along with the official repositories it can be helpful to have flatpak setup for installing and running prepackaged software.

```
pacman -S flatpak \
	xdg-desktop-portal \
	xdg-desktop-portal-kde\
	flatpak-kcm
flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo


flatpak update                   # update packages
flatpak search markdown          # search by keywords in package descriptions
flatpak install Obsidian         # Install a package
flatpak run md.obsidian.Obsidian # Run the package, will also be added to launcher after reboot or logout/login.
```

## Network Filesystem (NFS)
```bash
# Change value
MY_NFS_SERVER_IP=192.168.0.10
MY_SERVER_SHARE=/FirstPool/NAS
MY_LOCAL_DIRECTORY=/mnt/NAS

# Get NFS-utils to be able to mount nfs shares
pacman -S nfs-utils

# Show any shares exported by the NFS server
showmount -e $MY_NFS_SERVER_IP

# Mount a remote location to a local folder
sudo mount -t nfs -o vers=4 $MY_NFS_SERVER_IP:$MY_SERVER_SHARE $MY_LOCAL_DIRECTORY
```

Alternative to make it a mount on boot add to your /etc/fstab

Make a folder to map the NFS mount to and add mapping.  `mkdir -p /home/shaun/NAS` for example and server with share at IP 192.168.0.10

```
192.168.0.10:/FirstPool/NAS /home/shaun/NAS nfs4 defaults,user,exec 0 0
```