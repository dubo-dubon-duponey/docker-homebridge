#!/usr/bin/env bash
########################################################################################################################
# Common helpers
########################################################################################################################
# Err on anything
set -e

helpers::avahi(){
  # On container restart, cleanup the crap
  rm -f /var/run/dbus/pid
  rm -f /run/avahi-daemon/pid

  # Not really useful, but then
  dbus-uuidgen --ensure

  # https://linux.die.net/man/1/dbus-daemon-1
  dbus-daemon --system

  until [ -e /var/run/dbus/system_bus_socket ]; do
    sleep 1s
  done

  # Set the hostname, if we have it
  sed -i'' -e "s,%AVAHI_NAME%,$AVAHI_NAME,g" /etc/avahi/avahi-daemon.conf

  # https://linux.die.net/man/8/avahi-daemon
  avahi-daemon --daemonize --no-chroot
}

########################################################################################################################
# Specific to this image
########################################################################################################################
helpers::avahi
exec node_modules/.bin/homebridge -P /root/.homebridge/plugins "$@"
