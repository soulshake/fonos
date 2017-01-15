PACMD=pacmd

$PACMD unload-module module-null-sink
$PACMD unload-module module-rtp-send
$PACMD unload-module module-rtp-recv
$PACMD unload-module module-combine-sink

ALL_CARDS=$($PACMD list-sinks \
            | sed -n 's/^\s*name: <\(.*\)>$/\1/p' \
            | grep -v alsa_output.0 \
            | tr "\n" ",")
$PACMD load-module \
  module-combine-sink \
  sink_name=allthecards \
  adjust_time=1 \
  slaves=$ALL_CARDS

$PACMD load-module module-rtp-send source=allthecards.monitor
$PACMD load-module module-rtp-recv

# then:
# $PACMD list-sink-inputs # to find the id of the berry stream
# $PACMD move-sink-input 3 allthecards
# $PACMD move-sink-input 3 alsa_output.0.analog-stereo
# $PACMD move-sink-input 3 alsa_output.usb-Native_Instruments_Traktor_Kontrol_S8_3C9A9BB9-00-S8.analog-surround-40

# Also for Fanko:
# $PACMD load-module module-native-protocol-tcp auth-anonymous=1
# (allow network clients to control to Pulse e.g. to manipulate outputs etc)

# Also fanko:
# $PACMD load-module module-switch-on-port-available
# (when a sink (i.e. a sound card) is detected, move streams to it)
# There is a stock module "rescue" that does the opposite,
# i.e. when a sink is disconnected, move its stream to another working sink

