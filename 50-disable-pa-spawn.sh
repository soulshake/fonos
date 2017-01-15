#!/bin/sh
LINE="autospawn = no"
grep -q "^$LINE" /etc/pulse/client.conf || echo "$LINE" >> /etc/pulse/client.conf
