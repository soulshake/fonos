#!/bin/bash

php -S 0.0.0.0:8000 -t PaWebControl/source/
mopidy --config mopidy.conf
pulseaudio
pacmd load-module module-native-protocol-tcp auth-anonymous=1
