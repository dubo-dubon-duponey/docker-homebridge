#######################
# Extra builder for healthchecker
#######################
FROM          --platform=$BUILDPLATFORM dubodubonduponey/base:builder                                                   AS builder-healthcheck

ARG           HEALTH_VER=51ebf8ca3d255e0c846307bf72740f731e6210c3

WORKDIR       $GOPATH/src/github.com/dubo-dubon-duponey/healthcheckers
RUN           git clone git://github.com/dubo-dubon-duponey/healthcheckers .
RUN           git checkout $HEALTH_VER
RUN           arch="${TARGETPLATFORM#*/}"; \
              env GOOS=linux GOARCH="${arch%/*}" go build -v -ldflags "-s -w" -o /dist/bin/http-health ./cmd/http

RUN           chmod 555 /dist/bin/*

#######################
# Building image
#######################
FROM          dubodubonduponey/base:builder                                                                             AS builder

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
COPY          --from=builder --chown=$BUILD_UID:root /build/node /app
COPY          --from=builder-healthcheck  /dist/bin/http-health /boot/bin/
# RUN           find /app -type d -exec chmod -R 770 {} \; && find /config -type f -exec chmod -R 660 {} \;

USER          root

RUN           apt-get update -qq && \
              apt-get install -qq --no-install-recommends \
                nodejs=10.15.2~dfsg-2 \
                dbus=1.12.16-1 \
                avahi-daemon=0.7-4+b1 \
                libnss-mdns=0.14.1-1 && \
              apt-get -qq autoremove      && \
              apt-get -qq clean           && \
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
