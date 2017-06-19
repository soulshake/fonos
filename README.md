# Fonos

Open source multi-room speaker system for Raspberry Pis

## Dependencies

- a flash card of at least 4GB or so
- a Raspberry Pi (we're using a Raspberry Pi 3)
- a way to burn images to SD cards (we recommend [Etcher](https://etcher.io/))

## Setup (local)

Download [Raspbian Jessie Lite](https://www.raspberrypi.org/downloads/raspbian/) and burn it to your SD card with Etcher, `dd` or your favorite method.

With the SD card inserted into your computer, list the SD card devices by running `sudo fdisk -l`. You should see output like this:

Note: the rest of this tutorial assumes you will set the hostname of your Pi to be `fonos`.

```
Device         Boot Start      End  Sectors  Size Id Type
/dev/mmcblk0p1       8192    92159    83968   41M  c W95 FAT32 (LBA)
/dev/mmcblk0p2      92160 31116287 31024128 14.8G 83 Linux
```

### Enable SSH

- Create the target directory if it doesn't exist already: `sudo mkdir -p /media/pi`
- Mount the SD card's boot device (the `FAT32` one): `sudo mount /dev/mmcblk0p1 /media/pi`
- Create a file called `ssh` at the root of the boot partition: `sudo touch /media/pi/ssh`
- Unmount: `sudo umount /media/pi`

### Non-boot device

- Mount the second device: `sudo mount /dev/mmcblk0p2 /media/pi/`
- Enter the mount directory: `cd /media/pi`
- Change the hostname: `echo "fonos" | sudo tee etc/hostname`
- Modify the hosts file: `sudo sed -i "s/raspberrypi\$/fonos/" etc/hosts`

### Network setup

If you intend to connect your Pi to your router directly via ethernet, you can skip this step.

If you want to interact with your Pi over wifi, add the following snippet (with your own SSID and passphrase) to `etc/network/interfaces`:

```
iface wlan0 inet dhcp
        wpa-ssid "yourCleverWiFiSSID"
        wpa-psk "yourWiFipassword"
```

## Connecting to the Pi

Plug your Pi in and give it a few minutes to boot.

SSH in as the `pi` user by running `ssh pi@fonos.local`. The default password is `raspberry`.

From the Pi, run `mkdir ~/.ssh`, then add your public SSH key to `~/.ssh/authorized_keys`. If you don't know how to do this, see the first few steps at the [GitHub tutorial on SSH keys](https://help.github.com/articles/connecting-to-github-with-ssh/).

Exit (`exit` or `Ctrl-D`), then ssh to the Pi again to make sure you're not prompted for a password.

Once you've verified you can ssh without a password, disable password login on the Pi:

`echo "PasswordAuthentication No" | sudo tee -a /etc/ssh/ssh_config`

For extra security, change the password for the `pi` user with the `passwd` command.


## Deployment (on the Pi)

Run the following commands on the Pi to set things up:

- Install `git` and `pip`: `sudo apt update && sudo apt install git python-pip`
- Install Ansible: `sudo pip install ansible`
- Clone this repo: `cd ~ && git clone git@github.com:soulshake/fonos.git && cd fonos`
- Append the contents of `hosts.sample` to `/etc/ansible/hosts`: `cat hosts.sample | sudo tee -a /etc/ansible/hosts`
- Customize the Ansible hosts file: `sudo vim /etc/ansible/hosts`
  - add your own `spotify_username` and `spotify_password`
  - replace the hosts under `[fonos]` with the hostname you chose earlier plus a `.local` extension (in our case, `fonos.local`)
- Run the playbook: `ansible-playbook playbook.yml`

Once the playbook has completed, mopidy should be accessible at [http://fonos.local:6680/mopidy/](http://fonos.local:6680/mopidy/).

## Configuration

Config files are located in `/home/pi/.config/`. 

To view your current config as seen by the Mopidy service:

- `source /home/pi/fonos/env/bin/activate`
- `mopidy config`


## Troubleshooting

Mopidy is running as a systemd user unit. In other words, it is running as a user service (as opposed to a system service).

You can check its status, reload or restart it by running:

- `systemctl --user status mopidy`
- `systemctl --user reload mopidy`
- `systemctl --user restart mopidy`

Sometimes the PulseAudio daemon needs to be kicked: 

- `systemctl --user status pulseaudio`

By running as a user service, we can be independent from system config files as much as possible.

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
