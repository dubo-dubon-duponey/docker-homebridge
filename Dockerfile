# XXX move to buster on July/10
FROM node:dubnium-stretch-slim AS builder
MAINTAINER dubo-dubon-duponey@jsboot.space

# Install dependencies and tools
RUN apt-get update && \
    apt-get install -y libavahi-compat-libdnssd-dev git
#    git python make g++ inetutils-ping sudo apt-utils apt-transport-https curl wget libnss-mdns avahi-discover libkrb5-dev ffmpeg nano vim

WORKDIR /build
#  && mkdir /homebridge \
#  && npm set global-style=true \
#  && npm set package-lock=false

ENV HOMEBRIDGE_VERSION=0.4.50
RUN yarn add homebridge@${HOMEBRIDGE_VERSION}

# Plugins we like
RUN yarn add git://github.com/dubo-dubon-duponey/homebridge-roku --network-timeout 100000
RUN cd node_modules/homebridge-roku && yarn

RUN yarn add git://github.com/dubo-dubon-duponey/homebridge-weather-plus --network-timeout 100000
RUN cd node_modules/homebridge-weather-plus && yarn

RUN yarn add git://github.com/dubo-dubon-duponey/homebridge-dyson-link --network-timeout 100000
RUN cd node_modules/homebridge-dyson-link && yarn

RUN yarn add git://github.com/dubo-dubon-duponey/homebridge-pc-volume --network-timeout 100000
RUN cd node_modules/homebridge-pc-volume && yarn && yarn build

# UI is annoying and useless
# ENV CONFIG_UI_VERSION=4.5.1
# RUN yarn add homebridge-config-ui-x@${CONFIG_UI_VERSION} --network-timeout 100000
# homebridge-hue-scenes - meh

# Interesting: https://www.npmjs.com/package/homebridge-http-base

#######################
# Usual avahi/dbus image
#######################
FROM node:dubnium-stretch-slim AS runner
MAINTAINER dubo-dubon-duponey@jsboot.space

WORKDIR /dubo-dubon-duponey
RUN apt-get update \
  && apt-get install -y --no-install-recommends dbus avahi-daemon \
  && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
RUN mkdir -p /var/run/dbus
COPY avahi-daemon.conf /etc/avahi/avahi-daemon.conf

#######################
# Homebridge specific section
#######################
RUN apt-get update \
  && apt-get install -y --no-install-recommends libnss-mdns libasound2 alsa-utils \
  && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

COPY --from=builder /build /dubo-dubon-duponey

EXPOSE 5353
EXPOSE 51826
VOLUME [ "/root/.homebridge" ]

#######################
# Entrypoint
#######################
COPY entrypoint.sh .
ENTRYPOINT ["./entrypoint.sh"]
