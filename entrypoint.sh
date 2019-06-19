#!/usr/bin/env bash

dbus-daemon --system
avahi-daemon -D

node_modules/.bin/homebridge -P /root/.homebridge/plugins
