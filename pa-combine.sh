#!/bin/sh
PACMD=pacmd

$PACMD unload-module module-combine-sink || true

$PACMD load-module \
  module-combine-sink \
  sink_name=all_except_builtin \
  adjust_time=1 \
  slaves=$($PACMD list-sinks \
            | sed -n 's/^\s*name: <\(.*\)>$/\1/p' \
            | grep -e alsa_output.usb -e bluez \
            | tr "\n" ",")

pacmd update-sink-proplist alsa_output.usb-UC_MIC_ATR2USB-00-ATR2USB.analog-stereo \
	device.description="Yamahawesome.Speakers"
pacmd update-sink-proplist alsa_output.usb-C-Media_Electronics_Inc._USB_Audio_Device-00-Device.analog-stereo \
	device.description="Sound.Bar"
pacmd update-sink-proplist all_except_builtin \
	device.description="ALL.THE.SPEAKERS"
pacmd update-sink-proplist bluez_sink.08_DF_1F_F1_A1_9B \
	device.description="BOSE.White"
pacmd update-sink-proplist tunnel.up.local.bluez_sink.08_DF_1F_9D_5E_10 \
	device.description="BOSE.Black"

