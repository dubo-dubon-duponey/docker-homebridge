FROM node:dubnium-stretch-slim AS builder
MAINTAINER dubo-dubon-duponey@jsboot.space

# Install dependencies and tools
RUN apt-get update && \
    apt-get install -y libavahi-compat-libdnssd-dev
#    git python make g++ inetutils-ping sudo apt-utils apt-transport-https curl wget libnss-mdns avahi-discover libkrb5-dev ffmpeg nano vim

WORKDIR /build
#  && mkdir /homebridge \
#  && npm set global-style=true \
#  && npm set package-lock=false

ENV HOMEBRIDGE_VERSION=0.4.50
RUN yarn add homebridge@${HOMEBRIDGE_VERSION}

ENV CONFIG_UI_VERSION=4.5.1
RUN yarn add homebridge-config-ui-x@${CONFIG_UI_VERSION} --network-timeout 100000
RUN yarn add homebridge-dyson-link homebridge-hue-scenes




FROM node:dubnium-stretch-slim AS runner
MAINTAINER dubo-dubon-duponey@jsboot.space

# Install dependencies and tools
RUN apt-get update \
  && apt-get install -y --no-install-recommends dbus libnss-mdns avahi-discover \
  && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

RUN mkdir -p /var/run/dbus

WORKDIR /dubo-dubon-duponey

COPY --from=builder /build /dubo-dubon-duponey

COPY entrypoint.sh .
COPY avahi-daemon.conf /etc/avahi/avahi-daemon.conf

EXPOSE 5353 51826
VOLUME [ "/root/.homebridge" ]

ENTRYPOINT ["./entrypoint.sh"]
