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
  sed -i'' -e "s,%AVAHI_NAME%,$AVAHI_NAME,g" /data/avahi-daemon.conf

  # https://linux.die.net/man/8/avahi-daemon
  avahi-daemon -f /data/avahi-daemon.conf --daemonize --no-chroot
}

########################################################################################################################
# Specific to this image
########################################################################################################################

# chroot --userspec=dubo-dubon-duponey /
helpers::dbus
helpers::avahi

# XXX Workaround glibc / QEMU bug on arm
arch="$(dpkg --print-architecture)"; \
case "${arch##*-}" in \
  armel)
    rm -Rf /etc/ssl/certs
    rm -Rf /usr/share/ca-certificates
    apt-get update -qq
    apt-get remove -qq --purge ca-certificates openssl
    apt-get install -qq --no-install-recommends curl ca-certificates
    update-ca-certificates
  ;;
  armhf)
    rm -Rf /etc/ssl/certs
    rm -Rf /usr/share/ca-certificates
    apt-get update -qq
    apt-get remove -qq --purge ca-certificates openssl
    apt-get install -qq --no-install-recommends curl ca-certificates
    update-ca-certificates
  ;;
esac

exec chroot --userspec=dubo-dubon-duponey / /app/node_modules/.bin/homebridge --user-storage-path /data -P /config "$@"
