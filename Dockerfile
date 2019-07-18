##########################
# Building image
##########################
FROM        node:dubnium-stretch-slim                                                                     AS builder

MAINTAINER  dubo-dubon-duponey@jsboot.space
# Install dependencies and tools
ARG         DEBIAN_FRONTEND="noninteractive"
ENV         TERM="xterm" LANG="C.UTF-8" LC_ALL="C.UTF-8"
RUN         apt-get update                                                                                > /dev/null
RUN         apt-get install -y git libavahi-compat-libdnssd-dev                                           > /dev/null
WORKDIR     /build

# Versions: 0.4.50
ARG         HOMEBRIDGE_VERSION=84b4733ac75aba9e7c19d36be282cd8162077860
ARG         ROKU_VERSION=b99bfaab55b5c973495cd00d0aee81676926450e
ARG         WEATHER_VERSION=4ad21db38b9a4b5bd5b84e49f424b6a5270b21c0
ARG         DYSON_VERSION=176de27844a402a1e3f05d8105b1ff78c5f86ebb
ARG         VOLUME_VERSION=0301e4ab9baa4fa6420278cd8e610f07e5e4a92b

RUN         yarn init -p -y
RUN         yarn add git://github.com/nfarina/homebridge#${HOMEBRIDGE_VERSION}
RUN         yarn add git://github.com/dubo-dubon-duponey/homebridge-roku#${ROKU_VERSION}            --ignore-engines --network-timeout 100000 > /dev/null
RUN         yarn add git://github.com/dubo-dubon-duponey/homebridge-weather-plus#${WEATHER_VERSION} --ignore-engines --network-timeout 100000 > /dev/null
RUN         yarn add git://github.com/dubo-dubon-duponey/homebridge-dyson-link#${DYSON_VERSION}     --ignore-engines --network-timeout 100000 > /dev/null
RUN         yarn add git://github.com/dubo-dubon-duponey/homebridge-pc-volume#${VOLUME_VERSION}     --ignore-engines --network-timeout 100000 > /dev/null
RUN         cd node_modules/homebridge-pc-volume && yarn && yarn build

#######################
# Running image
#######################
FROM        node:dubnium-stretch-slim

MAINTAINER  dubo-dubon-duponey@jsboot.space
ARG         DEBIAN_FRONTEND="noninteractive"
ENV         TERM="xterm" LANG="C.UTF-8" LC_ALL="C.UTF-8"
RUN         apt-get update              > /dev/null && \
            apt-get dist-upgrade -y                 && \
            apt-get install -y --no-install-recommends dbus avahi-daemon libnss-mdns libasound2 alsa-utils \
                                        > /dev/null && \
            apt-get -y autoremove       > /dev/null && \
            apt-get -y clean            && \
            rm -rf /var/lib/apt/lists/* && \
            rm -rf /tmp/*               && \
            rm -rf /var/tmp/*

WORKDIR     /dubo-dubon-duponey
RUN         mkdir -p /var/run/dbus
COPY        avahi-daemon.conf /etc/avahi/avahi-daemon.conf
COPY        entrypoint.sh .

COPY        --from=builder /build .

EXPOSE      5353
EXPOSE      51826
VOLUME      "/root/.homebridge"

ENTRYPOINT  ["./entrypoint.sh"]






# XXX notes
#    git python make g++ inetutils-ping sudo apt-utils apt-transport-https curl wget libnss-mdns avahi-discover libkrb5-dev ffmpeg nano vim
# UI is annoying and useless
# ENV CONFIG_UI_VERSION=4.5.1
# RUN yarn add homebridge-config-ui-x@${CONFIG_UI_VERSION} --network-timeout 100000
# homebridge-hue-scenes - meh

# Interesting: https://www.npmjs.com/package/homebridge-http-base

#  && mkdir /homebridge \
#  && npm set global-style=true \
#  && npm set package-lock=false

