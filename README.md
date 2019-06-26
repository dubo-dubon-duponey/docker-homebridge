# What

A docker image for [homebridge](https://github.com/nfarina/homebridge).

 * multi-architecture (linux/amd64, linux/arm64, linux/arm/v7)
 * based on dubnium debian:stretch-slim
 * contains connectors for Dyson air purifiers and alsa volume control

## Run

```bash
docker run -d \
    --net=host \
    --device /dev/snd \
    --volume [host_path]:/root/.homebridge \
    --env AVAHI_NAME="My Homebridge server name" \
    dubodubonduponey/homebridge:v1
```

## Notes

### Network

 * `bridge` mode will NOT work for discovery, since mDNS will not broadcast on your lan subnet (you may still access the server explicitely on port 548)
 * `host` (default, easy choice) is only acceptable as long as you DO NOT have any other containers running on the same ip using avahi

If you intend on running multiple containers relying on avahi, you may want to consider `macvlan`.

TL;DR:

```bash
docker network create -d macvlan \
  --subnet=192.168.1.0/24 \
  --ip-range=192.168.1.128/25 \
  --gateway=192.168.1.1 \
  -o parent=eth0 hackvlan
  
docker run -d --env AVAHI_NAME=N1 --name=N1 --device /dev/snd --volume [host_path]:/root/.homebridge --network=hackvlan dubodubonduponey/homebridge:v1
docker run -d --env AVAHI_NAME=N2 --name=N2 --device /dev/snd --volume [host_path_2]:/root/.homebridge --network=hackvlan dubodubonduponey/homebridge:v1
```

Need help with macvlan?
[Hit yourself up](https://docs.docker.com/network/macvlan/).

### Configuration

Everything is in the mounted volume as far as Homebridge is concerned.

You only need to use `/dev/snd` if the target is a speaker and you intend on using volume control.

### Advanced configuration

Would you need to, you may optionally pass along:
 
 * `--volume [host_path]/avahi-daemon.conf:/etc/avahi/avahi-daemon.conf`

Also, any additional arguments when running the image will get fed to the `homebridge` binary.

Typical Dyson configuration:
```json
{
  "platforms": [{
    "platform": "DysonPlatform",
    "name": "Something Fancy",
    "email": "dyson-registration-email",
    "password": "dyson-website-password",
    "country": "US",
    "accessories": [{
      "ip": "ip_of_the_dyson_device",
      "email": "dyson-registration-email",
      "password": "dyson-website-password",
      "displayName": "Something Really Fancy",
      "serialNumber": "NM7-US-XXXXXXXX",
      "nightModeVisible" : true,
      "focusModeVisible" : true,
      "autoModeVisible" : true
    }]
  }]
}
```

Typical speaker configuration:
````json
{
  "accessories": [{
    "accessory": "ComputerSpeakers",
    "name": "Something Fancy",
    "device": "Digital",
    "card": "2",
    "services": ["fan"]
  }]
}
````

Both `device` and `card` are optional, and allows you to use a non-default mixer (first mixer found by aplay) or card (alsa default card).

`services` allows you to select different display controls (either "fan" or "lightbulb") in "Home".

Note that the speaker backend has been forked from their upstream projects to support card and device selection.

See dockerfile for source.
