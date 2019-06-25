#!/usr/bin/env bash

# Useful on a container restart
rm -f /var/run/dbus/pid
rm -f /run/avahi-daemon/pid

dbus-uuidgen --ensure
dbus-daemon --system
avahi-daemon --daemonize --no-chroot

exec node_modules/.bin/homebridge -P /root/.homebridge/plugins "$@"
