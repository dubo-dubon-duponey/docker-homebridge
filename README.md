# What

Docker image for a "Homebridge" server.

This is based on [homebridge](https://github.com/nfarina/homebridge).

Additionally contains connectors for Dyson air purifiers, Roku, Weather, and Alsa volume control.

## Image features

 * multi-architecture:
    * [x] linux/amd64
    * [x] linux/arm64
    * [x] linux/arm/v7
    * [ ] ~~linux/arm/v6~~ no nodejs for v6
 * hardened:
    * [x] image runs read-only
    * [ ] image runs with the following capabilities:
        * SYS_CHROOT
        * DAC_OVERRIDE
        * CHOWN
        * SETUID
        * SETGID
    * [ ] process runs as a non-root user, disabled login, no shell
        * the entrypoint script still runs as root before dropping privileges (due to avahi-daemon)
 * lightweight
    * [x] based on our slim [Debian buster version](https://github.com/dubo-dubon-duponey/docker-debian)
    * [x] simple entrypoint script
    * [ ] multi-stage build with ~~no installed~~ dependencies for the runtime image:
        * dbus
        * avahi-daemon
        * libnss-mdns
 * observable
    * [TODO] healthcheck
    * [x] log to stdout
    * [ ] ~~prometheus endpoint~~ not applicable

## Run

```bash
docker run -d \
    --net=host \
    --device /dev/snd \
    --volume [host_path]:/config \
    --env AVAHI_NAME="My Homebridge server name" \
    --cap-drop ALL \
    --cap-add SYS_CHROOT \
    --cap-add DAC_OVERRIDE \
    --cap-add CHOWN \
    --cap-add SETUID \
    --cap-add SETGID \
    --read-only \
    dubodubonduponey/homebridge:v1
```

## Notes

### Network

 * `bridge` mode will NOT work for discovery, since mDNS will not broadcast on your lan subnet (you may still access the server explicitely on port 548)
 * `host` (default, easy choice) is only acceptable as long as you DO NOT have any other containers running on the same ip using avahi

If you intend on running multiple containers relying on Avahi, you may want to consider `macvlan`.

TL;DR:

```bash
docker network create -d macvlan \
  --subnet=192.168.1.0/24 \
  --ip-range=192.168.1.128/25 \
  --gateway=192.168.1.1 \
  -o parent=eth0 hackvlan
```

Need help with macvlan?
[Hit yourself up](https://docs.docker.com/network/macvlan/).

### Configuration

Everything is in the mounted volume as far as Homebridge is concerned.

You only need to use `/dev/snd` if the target is a speaker and you intend on using volume control.

### Advanced configuration

You can additionally mount `/data`, would you need to customize `avahi-daemon.conf`.
 
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

## Moar?

See [DEVELOP.md](DEVELOP.md)
