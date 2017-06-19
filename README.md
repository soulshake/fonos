# Fonos

Open source multi-room speaker system for Raspberry Pis

## Dependencies

- a flash card of at least 4GB
- a Raspberry Pi
- a way to burn images to SD cards (we recommend [Etcher](https://etcher.io/) recommended)
- git
- Ansible

## Setup

1. Download [Raspbian Jessie Lite](https://www.raspberrypi.org/downloads/raspbian/)

2. Burn it to your SD card with Etcher

3. Enable SSH, change the hostname, and enable wifi (optional)


Get the devices by running: `sudo fdisk -l`. You should see output like this:

```
Device         Boot Start      End  Sectors  Size Id Type
/dev/mmcblk0p1       8192    92159    83968   41M  c W95 FAT32 (LBA)
/dev/mmcblk0p2      92160 31116287 31024128 14.8G 83 Linux
```

### Enable SSH

- Create the target directory if it doesn't exist already: `sudo mkdir -p /media/pi`
- Mount the boot device (the `FAT32` one): `sudo mount /dev/mmcblk0p1 /media/pi`
- Enter the mount directory: `cd /media/pi`
- Create a file called `ssh` at the root of the boot partition: `sudo touch ssh`
- Leave the directory so you can unmount: `cd ~`
- Unmount: `sudo umount /media/pi`

### Non-boot device

- Mount the second device: `sudo mount /dev/mmcblk0p2 /media/pi/`
- Enter the mount directory: `cd /media/pi`
- Change the hostname: `echo "fonos" | sudo tee etc/hostname`
- Modify the hosts file: `sudo sed -i "s/raspberrypi\$/fonos/" etc/hosts`

Add the following to `etc/network/interfaces`:

```
iface wlan0 inet dhcp
        wpa-ssid "yourCleverWiFiSSID"
        wpa-psk "yourWiFipassword"
```


## Deploying it

SSH to the pi: `ssh pi@fonos.local` (or just `pi@fonos` from a Mac)
The default password is `raspberry`.

From the pi, run these commands:

- `mkdir ~/.ssh`
- Add your public key to `~/.ssh/authorized_keys`

Exit, then ssh again to make sure you're not prompted for a password.

Once you're sure you can ssh without a password, disable password login:

`echo "PasswordAuthentication No" | sudo tee -a /etc/ssh/ssh_config`

And change the default password: `passwd`

Run the following commands to set things up:

- `sudo apt update`
- `sudo apt install git python-pip`
- `sudo pip install ansible`
- clone the repo: `git clone git@github.com:soulshake/fonos.git && cd fonos`
- append hosts.sample to `/etc/ansible/hosts`: `cat hosts.sample | sudo tee -a /etc/ansible/hosts`
- customize hosts : `sudo vim /etc/ansible/hosts`
  - add your own `spotify_username` and `spotify_password`
  - replace the hosts under `[fonos]` with the hostname you chose earlier plus a `.local` extension (in our case, `fonos.local`)
- Run the playbook: `ansible-playbook playbook.yml`

## Principles

- systemd user units
- user configuration files (in ~/.config)
- try to be independent from system config files as much as possible

