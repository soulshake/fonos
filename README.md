# Fonos

Fonos is an open source multi-room speaker system for Raspberry Pi inspired by Sonos. Unlike Sonos, it can be used with your own speakers.

## Dependencies

- a flash card of at least 4GB or so
- a Raspberry Pi (we're using a Raspberry Pi 3)
- a way to burn images to SD cards (we recommend [Etcher](https://etcher.io/))

## Setup (local)

Note: the rest of this tutorial assumes you will set the hostname of your Pi to be `fonos`. (If you're setting up more than one Pi, be sure to use a different hostname for each one, like `fonos2`.)

Download the [Raspbian Jessie Lite](https://www.raspberrypi.org/downloads/raspbian/) image and burn it to your SD card with Etcher, `dd` or your own favorite method.

With the SD card inserted into your computer, list the SD card devices by running `sudo fdisk -l`. You should see output like this:

```
Device         Boot Start      End  Sectors  Size Id Type
/dev/mmcblk0p1       8192    92159    83968   41M  c W95 FAT32 (LBA)
/dev/mmcblk0p2      92160 31116287 31024128 14.8G 83 Linux
```

### Enable SSH

#### Create a target directory on your host if it doesn't exist already (we'll use `/media/pi/`)

`sudo mkdir -p /media/pi`

#### Mount the SD card's boot device (the `FAT32` one)

`sudo mount /dev/mmcblk0p1 /media/pi`

#### Create a file called `ssh` at the root of the boot partition

`sudo touch /media/pi/ssh`

#### Unmount (but don't physically eject the SD card yet)

`sudo umount /media/pi`

### Change the Pi hostname

The default Pi hostname is `raspberrypi`. We'll give ours a custom hostname, `fonos`, so its web interface can later be accessed at `http://fonos.local`.

To do so:

####  Mount the second (non-boot) SD card device

`sudo mount /dev/mmcblk0p2 /media/pi/`

#### Change the hostname

`echo "fonos" | sudo tee /media/pi/etc/hostname`

#### Modify the hosts file to replace `raspberrypi` with `fonos`

`sudo sed -i s/raspberrypi/fonos/ /media/pi/etc/hosts`

#### Network setup

_If you intend to connect your Pi directly to your router via ethernet, you can skip this step._

Otherwise, if you want to interact with your Pi over wifi, append the following snippet (with your own SSID and passphrase) to `/media/pi/etc/network/interfaces`:

```
iface wlan0 inet dhcp
        wpa-ssid "yourCleverWiFiSSID"
        wpa-psk "yourWiFipassword"
```

#### Unmount and eject

`sudo umount /media/pi`

Physically eject the SD card from your computer and insert it into your Pi.

## Connecting to the Pi

Plug your Pi into a micro USB power source and give it a few minutes to boot.

SSH in as the `pi` user by running `ssh pi@fonos.local`. The default password is `raspberry`.

### SSH key authentication

_If you don't mind typing a password every time you SSH to the Pi, you can skip this step._

From the Pi, run `mkdir ~/.ssh`, add your public SSH key to `~/.ssh/authorized_keys` (you'll need to create this file). If you don't know how to do this, see the first few steps at the [GitHub tutorial on SSH keys](https://help.github.com/articles/connecting-to-github-with-ssh/).

Exit (`exit` or `Ctrl-D`), then SSH to the Pi again to make sure you're not prompted for a password.

Once you've verified you can `ssh pi@fonos.local` without being prompted for a password, you should disable password login on the Pi:

`echo "PasswordAuthentication No" | sudo tee -a /etc/ssh/ssh_config`

### Change the password

For extra security, you should change the password for the `pi` user by running the `passwd` command (especially if you didn't disable password login in the step above).

## Deployment (on the Pi)

SSH to the Pi and complete the following steps:

#### Install `git` and `pip`

`sudo apt update && sudo apt install git python-pip`

#### Install Ansible

`sudo pip install ansible`

#### Clone this repo

`cd ~ && git clone git@github.com:soulshake/fonos.git && cd fonos`

#### Append the contents of `hosts.sample` to `/etc/ansible/hosts`

`cat hosts.sample | sudo tee -a /etc/ansible/hosts`

#### Customize the Ansible hosts file

`sudo vi /etc/ansible/hosts`

- add your own `spotify_username` and `spotify_password`
- replace the hosts under `[fonos]` with the hostname you chose earlier plus a `.local` extension (in our case, `fonos.local`)

#### Run the Ansible playbook

`ansible-playbook playbook.yml`

Once the playbook has completed, mopidy should be accessible at [http://fonos.local:6680/mopidy/](http://fonos.local:6680/mopidy/).

## Configuration

Config files are located in `/home/pi/.config/`. 

To view your current config as seen by the Mopidy service:

- `source /home/pi/fonos/env/bin/activate`
- `mopidy config`


## Troubleshooting

Mopidy is running as a systemd user unit. By running as a user service (as opposed to a system service), we can avoid dealing with system config files as much as possible and be self-contained within the `pi` user's home directory.

You can check the `mopidy` service status, reload it or restart it by running:

- `systemctl --user status mopidy`
- `systemctl --user reload mopidy`
- `systemctl --user restart mopidy`
- etc.

Occasionally the PulseAudio daemon can crash; you can check it by running `systemctl --user status pulseaudio`.


### I can view the web interfaces but nothing is playing

Ensure your credentials are correct in the output of `mopidy config` as described in [Configuration](#Configuration).

Try downloading an mp3 directly to the Pi:

`wget https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3 /home/pi/fonos`

You should be able to see it under `Files` in the [Moped interface](http://fonos.local:6680/moped), for example. If it plays through your speakers, there might be an issue with your credentials for the service you're trying to play through (e.g. Spotify/Soundcloud/etc).


### The interface shows that it's playing, but I don't hear any sound

- Ensure your Pi is connected to your speaker via audio cable.
- Ensure your speaker is plugged in and on.

This may sound obvious, but it happens to the best of us :)


### Debug logging

FIXME
