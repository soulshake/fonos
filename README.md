# Fonos

Open source multi-room speaker system for Raspberry Pis

## Dependencies

- a flash card of at least 4GB or so
- a Raspberry Pi (we're using a Raspberry Pi 3)
- a way to burn images to SD cards (we recommend [Etcher](https://etcher.io/))
- git
- Ansible

## Setup

1. Download [Raspbian Jessie Lite](https://www.raspberrypi.org/downloads/raspbian/)
2. Burn it to your SD card with Etcher
3. Enable SSH, change the hostname, and enable wifi (optional)


List the SD card devices by running `sudo fdisk -l`. You should see output like this:

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
- Install Ansible: `sudo pip install ansible`
- Clone the repo: `cd ~ && git clone git@github.com:soulshake/fonos.git && cd fonos`
- Append the contents of `hosts.sample` to `/etc/ansible/hosts`: `cat hosts.sample | sudo tee -a /etc/ansible/hosts`
- Customize the Ansible hosts file: `sudo vim /etc/ansible/hosts`
  - add your own `spotify_username` and `spotify_password`
  - replace the hosts under `[fonos]` with the hostname you chose earlier plus a `.local` extension (in our case, `fonos.local`)
- Run the playbook: `ansible-playbook playbook.yml`

Once the playbook has completed, mopidy should be accessible at [http://fonos.local:6680/mopidy/](http://fonos.local:6680/mopidy/) (or [http://fonos:6680/mopidy/](http://fonos:6680/mopidy/) from a Mac).

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
