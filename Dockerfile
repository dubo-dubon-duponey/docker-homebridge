FROM node:dubnium-stretch-slim AS builder
MAINTAINER dubodubonduponey@pm.me

# Install dependencies and tools
RUN apt-get update && \
    apt-get install -y libavahi-compat-libdnssd-dev
#    git python make g++ inetutils-ping sudo apt-utils apt-transport-https curl wget libnss-mdns avahi-discover libkrb5-dev ffmpeg nano vim

WORKDIR /homebridge

#  && mkdir /homebridge \
#  && npm set global-style=true \
#  && npm set package-lock=false

ENV HOMEBRIDGE_VERSION=0.4.50
RUN yarn add homebridge@${HOMEBRIDGE_VERSION}

ENV CONFIG_UI_VERSION=4.5.1
RUN yarn add homebridge-config-ui-x@${CONFIG_UI_VERSION}


FROM node:dubnium-stretch-slim AS runner

MAINTAINER dubodubonduponey@pm.me

# Install dependencies and tools
RUN apt-get update && \
    apt-get install -y libnss-mdns avahi-discover \
      && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/dbus

WORKDIR /homebridge

COPY --from=builder /homebridge /homebridge
COPY --from=builder /homebridge /homebridge

COPY avahi-daemon.conf /etc/avahi/avahi-daemon.conf
COPY entrypoint.sh .

# Run container
EXPOSE 5353 51826
ENTRYPOINT ["./entrypoint.sh"]
