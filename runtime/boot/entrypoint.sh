#!/usr/bin/env bash
########################################################################################################################
# Common helpers
########################################################################################################################
# Err on anything
# Note: bluetoothd might fail
set -e

helpers::dbus(){
  # On container restart, cleanup the crap
  rm -f /run/dbus/pid

  # https://linux.die.net/man/1/dbus-daemon-1
  dbus-daemon --system

  until [ -e /run/dbus/system_bus_socket ]; do
    sleep 1s
  done
}

helpers::avahi(){
  # On container restart, cleanup the crap
  rm -f /run/avahi-daemon/pid

  # Set the hostname, if we have it
  sed -i'' -e "s,%AVAHI_NAME%,$AVAHI_NAME,g" /config/avahi-daemon.conf

  # https://linux.die.net/man/8/avahi-daemon
  avahi-daemon -f /config/avahi-daemon.conf --daemonize # --no-chroot
}

########################################################################################################################
# Specific to this image
########################################################################################################################

# chroot --userspec=dubo-dubon-duponey /
helpers::dbus
helpers::avahi

exec chroot --userspec=dubo-dubon-duponey / /app/node_modules/.bin/homebridge --user-storage-path /data -P /config "$@"
