# Fonos

Fonos is an open source multi-room speaker system for Raspberry Pi.

## Dependencies

- a flash card of at least 4GB or so
- a Raspberry Pi (we're using a Raspberry Pi 3)
- a way to burn images to SD cards (we recommend [Etcher](https://etcher.io/))

## Setup (local)

Note: the rest of this tutorial assumes you will set the hostname of your Pi to be `fonos`. (If you're setting up more than one Pi, be sure to use a different hostname for each one.)

Download the [Raspbian Jessie Lite](https://www.raspberrypi.org/downloads/raspbian/) image and burn it to your SD card with Etcher, `dd` or your own favorite method.

With Etcher CLI, for example:

<pre>sudo etcher <b>~/Downloads/2017-04-10-raspbian-jessie-lite.img</b> --drive <b>/dev/mmcblk0</b></pre>

### Get the SD card devices

#### On Linux

With the SD card inserted into your computer, list the SD card devices by running `sudo fdisk -l`. On Linux, the output will look something like this:

<pre>
$ sudo fdisk -l

Disk <b>/dev/mmcblk0</b>: 14.9 GiB, 15931539456 bytes, 31116288 sectors
[...]

Device         Boot Start      End  Sectors  Size Id Type
<b>/dev/mmcblk0p1</b>       8192    92159    83968   41M  c W95 FAT32 (LBA)
<b>/dev/mmcblk0p2</b>      92160 31116287 31024128 14.8G 83 Linux
</pre>

In the output above:
- **`/dev/mmcblk0`** is the disk
- **`/dev/mmcblk0p1`** is the boot device
- **`/dev/mmcblk0p2`** is the non-boot device

#### On other platforms

FIXME

### Enable SSH

##### Create a target directory on your host if it doesn't exist already:

We'll use `/media/pi`:

`sudo mkdir -p /media/pi`

##### Mount the SD card's boot device:

<pre>sudo mount <b>/dev/mmcblk0p1</b> /media/pi</pre>

##### Create an empty file called `ssh` at the root of the boot partition to enable SSH on the Pi:

`sudo touch /media/pi/ssh`

##### Unmount (but don't physically eject the SD card yet):

`sudo umount /media/pi`


### Configure the Pi

The default Pi hostname is `raspberrypi`. We'll give ours a custom hostname, `fonos`, so its web interface can later be accessed at `http://fonos.local`. To do so:

#####  Mount the second (non-boot) SD card device:

<pre>sudo mount <b>/dev/mmcblk0p2</b> /media/pi/</pre>

##### Change the hostname:

<pre>echo "<b>fonos</b>" | sudo tee /media/pi/etc/hostname</pre>

##### Modify the hosts file to replace `raspberrypi` with your chosen hostname:

<pre>sudo sed -i s/raspberrypi/<b>fonos</b>/ /media/pi/etc/hosts</pre>

##### Network setup:

_If you intend to connect your Pi directly to your router via ethernet, you can skip this step._

If you want to interact with your Pi over wifi, append the following snippet (with your own SSID and passphrase) to `/media/pi/etc/network/interfaces`:


<pre>
iface wlan0 inet dhcp
        wpa-ssid "<b>yourCleverWiFiSSID</b>"
        wpa-psk "<b>yourWiFipassword</b>"
</pre>

##### Unmount and eject:

`sudo umount /media/pi`

Physically eject the SD card from your computer and insert it into your Pi.

## Connecting to the Pi

Plug your Pi into a micro USB power source and give it a few minutes to boot.

SSH in as the `pi` user by running <pre>ssh pi@<b>fonos</b>.local</pre>. The default password is `raspberry`.

Note: If you still can't connect via SSH after a few minutes, try connecting to your router's web interface to see if the device appears there. If it doesn't, it usually helps to unplug the Pi and plug it back in.

### SSH key authentication

_If you don't mind typing a password every time you SSH to the Pi, you can skip this step._

From the Pi, create the `~/.ssh/authorized_keys` file and add your public SSH key. If you don't know how to do this, see the first few steps at the [GitHub tutorial on SSH keys](https://help.github.com/articles/connecting-to-github-with-ssh/).

Exit, then SSH to the Pi again to make sure you're not prompted for a password.

Once you've verified you can `ssh pi@fonos.local` without being prompted for a password, you should disable password login on the Pi:

`echo "PasswordAuthentication No" | sudo tee -a /etc/ssh/ssh_config`


## Deployment

From your **local machine**, complete the following steps:

#### Install Ansible (version 2.0 or above)

See instructions for installing Ansible [here](http://docs.ansible.com/ansible/intro_installation.html).

#### Clone this repo

`git clone git@github.com:soulshake/fonos.git && cd fonos`

#### Create your Ansible inventory file (`hosts`)

From the root of the repo you just cloned, copy `hosts.sample` to `hosts` and modify it:

- add your own `spotify_username` and `spotify_password`, and credentials for other services you wish to enable
- replace the hosts under `[fonos]` with the hostname you chose earlier plus a `.local` extension (in our case, `fonos.local`)

The resulting `hosts` file should look something like this (if you have Pis with the hostnames `fonos` and `fonos2`):

<pre>
[fonos]
<b>fonos.local</b>
<b>fonos2.local</b>

[fonos:vars]
spotify_username=<b>your.spotify.username</b>
spotify_password=<b>yourSpotifyPa$$word</b>
</pre>

If you want to provision more Pis later, just add their hostnames under `[fonos]`.

#### Run the Ansible playbook

`ansible-playbook playbook.yml -i hosts`

Once the playbook has completed, mopidy should be accessible at [http://fonos.local:6680/mopidy/](http://fonos.local:6680/mopidy/).

Note: For some reason, the playbook sometimes fails the first time at the "enable systemd units" step. If this happens, retry by running:

`ansible-playbook playbook.yml -i hosts --start-at-task="enable systemd units"`

## Configuration

Config files are located on the Pi in `/home/pi/.config/`.

### To view your current config as seen by the Mopidy service

From the Pi, run:

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


### "I can view the web interfaces but nothing is playing"

Ensure your credentials are correct in the output of `mopidy config` as described in [Configuration](#Configuration).

Try downloading an mp3 directly to the Pi:

`wget https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3 /home/pi/fonos`

You should be able to see it under `Files` in the [Moped interface](http://fonos.local:6680/moped), for example. If it plays through your speakers, there might be an issue with your credentials for the service you're trying to play through (e.g. Spotify/Soundcloud/etc).


### "The interface shows that it's playing, but I don't hear any sound"

- Ensure your Pi is connected to your speaker via audio cable.
- Ensure your speaker is plugged in and on.

This may sound obvious, but it happens to the best of us :)


### Debug logging

FIXME


## Combining sinks

Download something to play:

`wget https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3 /home/pi/fonos`

Then navigate to `http://fonos.local:6680/moped` in a browser and play the track from the "Files" section.

Then, on the Pi, list sinks by name:

```
pacmd list-sinks | grep -i name:
	name: <alsa_output.0.analog-stereo>
	name: <tunnel.vorpal.local.alsa_output.pci-0000_00_03.0.hdmi-stereo>
	name: <tunnel.vorpal.local.alsa_output.pci-0000_00_1b.0.analog-stereo>
	name: <tunnel.vorpal.local.combined>
	name: <tunnel.fonos2.local.alsa_output.0.analog-stereo>
	name: <tunnel.fonos2.local.alsa_output.0.analog-stereo.2>
```

Create a combined output between our Pi's output (`alsa_output.0.analog-stereo`) and the corresponding output on the other pi (`tunnel.fonos2.local.alsa_output.0.analog-stereo`). (There's duplicates (with a `.2` suffix) because of ipv6.)

Create a new combined sink:

```
pacmd load-module module-combine-sink \
  sink_name=combined \
  slaves="alsa_output.0.analog-stereo,tunnel.fonos2.local.alsa_output.0.analog-stereo"
```

Now if you run `pacmd list-sinks | grep -i name:` again, you'll see the new sink:

```
	name: <combined>
```

A snippet to combine all USB sinks:

```
pacmd load-module module-combine-sink \
  sink_name=combined \
  slaves=$(pacmd list-sinks 
    | sed -n 's/^\s*name: <\(.*\)>$/\1/p' \
    | grep -e alsa_output.usb \
    | tr "\n" ",")
```

Open pavucontrol from your host with the `PULSE_SERVER` environment variable set to your Pi hostname:

`PULSE_SERVER=fonos.local pavucontrol`

In the **Playback** tab, you should be able to select the combined output.

All your speakers should now, in theory, be producing sound.


### Troubleshooting

If you can view the web interface but nothing seems to actually play, you may need to check on the Mopidy or PulseAudio services.

To view service logs:

- `sudo journalctl _SYSTEMD_USER_UNIT=mopidy.service`
- `sudo journalctl  _SYSTEMD_USER_UNIT=pulseaudio.service`

To restart Mopidy:

`systemctl --user restart mopidy.service`
