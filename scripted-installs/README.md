## Intro
Some quick scripts for setting up arch based installations targeting virtual machines.

Boot arch ISO and on the new arch install boot prompt run the first two commands.
Get the machine IP and use for the next two commands.

| Command                                   | Description                                   |
| ----------------------------------------- | --------------------------------------------- |
| `passwd`                                  | Set a root password                           |
| `ip -4 a`                                 | Check the ip                                  |
| `./arch-setup-0.sh`                       | Script will prompt for IP to connect          |
| `/arch-setup-1.sh`                        | Run script on remote machine after connection |

As the system installs you'll be prompted to enter a password for the "regular user" that will be setup.
After the system reboots run: `sudo /arch-setup-2.sh` to setup KDE Plasma desktop.
