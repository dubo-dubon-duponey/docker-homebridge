#######################
# Extra builder for healthchecker
#######################
ARG           BUILDER_BASE=dubodubonduponey/base:builder
ARG           RUNTIME_BASE=dubodubonduponey/base:runtime
# hadolint ignore=DL3006
FROM          --platform=$BUILDPLATFORM $BUILDER_BASE                                                                   AS builder-healthcheck

ARG           HEALTH_VER=51ebf8ca3d255e0c846307bf72740f731e6210c3

WORKDIR       $GOPATH/src/github.com/dubo-dubon-duponey/healthcheckers
RUN           git clone git://github.com/dubo-dubon-duponey/healthcheckers .
RUN           git checkout $HEALTH_VER
RUN           arch="${TARGETPLATFORM#*/}"; \
              env GOOS=linux GOARCH="${arch%/*}" go build -v -ldflags "-s -w" -o /dist/boot/bin/http-health ./cmd/http

#######################
# Building image
#######################
# hadolint ignore=DL3006
FROM          $BUILDER_BASE                                                                                             AS builder

WORKDIR       /dist/boot

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

COPY          --from=builder-healthcheck /dist/boot/bin           /dist/boot/bin
RUN           chmod 555 /dist/boot/bin/*

#######################
# Running image
#######################
# hadolint ignore=DL3006
FROM          $RUNTIME_BASE

COPY          --from=builder --chown=$BUILD_UID:root /dist .

# hadolint ignore=DL3002
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
              && chown "$BUILD_UID":root /run/dbus \
              && chmod 775 /run/dbus \
              && ln -s /config/config.json /data/config.json
# RUN           mkdir -p /run/avahi-daemon && chown $BUILD_UID:root /run/avahi-daemon && chmod 770 /run/avahi-daemon

VOLUME        /config
VOLUME        /data
VOLUME        /run

ENV           AVAHI_NAME="Farcloser Homebridge"
ENV           HEALTHCHECK_URL="http://127.0.0.1:5353"

# XXX healthcheck please
EXPOSE        5353
EXPOSE        51826

HEALTHCHECK --interval=30s --timeout=30s --start-period=10s --retries=1 CMD http-health || exit 1
