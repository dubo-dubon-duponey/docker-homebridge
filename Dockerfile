#######################
# Building image
#######################
FROM          dubodubonduponey/base:builder                                   AS builder

WORKDIR       /build/node

# Versions: 0.4.50
ARG           HOMEBRIDGE_VERSION=adb1f26ae26dc4ad47c8da682e9f251d7b201bbf
ARG           DYSON_VERSION=7e8d7b3654c33c205fb1cf5e5d44120220d4756e
ARG           ROKU_VERSION=b99bfaab55b5c973495cd00d0aee81676926450e
ARG           WEATHER_VERSION=45d3286b2f3e52d664ed745b9ce2eea462d3bcda

RUN           yarnpkg init -p -y
RUN           yarnpkg add git://github.com/dubo-dubon-duponey/homebridge#${HOMEBRIDGE_VERSION}
RUN           yarnpkg add git://github.com/dubo-dubon-duponey/homebridge-dyson-link#${DYSON_VERSION}     --ignore-engines --network-timeout 100000 > /dev/null
RUN           yarnpkg add git://github.com/dubo-dubon-duponey/homebridge-roku#${ROKU_VERSION}            --ignore-engines --network-timeout 100000 > /dev/null
RUN           yarnpkg add git://github.com/dubo-dubon-duponey/homebridge-weather-plus#${WEATHER_VERSION} --ignore-engines --network-timeout 100000 > /dev/null

#######################
# Running image
#######################
FROM          dubodubonduponey/base:runtime

WORKDIR       /app
# Get relevant bits from builder
COPY          --from=builder --chown=$BUILD_UID:0 /build/node /app
# RUN           find /app -type d -exec chmod -R 770 {} \; && find /config -type f -exec chmod -R 660 {} \;

USER          root

RUN           apt-get update              > /dev/null && \
              apt-get install -y --no-install-recommends \
                nodejs=10.15.2~dfsg-2 \
                dbus=1.12.16-1 \
                avahi-daemon=0.7-4+b1 \
                libnss-mdns=0.14.1-1      > /dev/null && \
              apt-get -y autoremove       > /dev/null && \
              apt-get -y clean            && \
              rm -rf /var/lib/apt/lists/* && \
              rm -rf /tmp/*               && \
              rm -rf /var/tmp/*

RUN           dbus-uuidgen --ensure \
              && mkdir -p /run/dbus \
              && chown $BUILD_UID:root /run/dbus \
              && chmod 775 /run/dbus \
              && ln -s /config/config.json /data/config.json
# RUN           mkdir -p /run/avahi-daemon && chown $BUILD_UID:root /run/avahi-daemon && chmod 770 /run/avahi-daemon

VOLUME        /config
VOLUME        /data
VOLUME        /run

ENV           AVAHI_NAME="Farcloser Homebridge"

EXPOSE        5353
EXPOSE        51826
