# adsb.lol docker feed client

The adsb.lol docker feed client is a toolkit that allows you to install, run and maintain a ADS-B / UAT / MLAT / ACARS / VDL2 feed client.

By default, it feeds MLAT+ADSB to adsb.lol. You can enable UAT/ACARS/VDL2, and feed to your plane data to FlightRadar24, Radarbox, Piaware, [and more](.env.example)

It is designed to be run on a Raspberry Pi, but can be run on any Linux Debian-like system.

With a few commands, you can easily feed to other community aggregators.

For an up to date version of the documentation, see [www.adsb.lol/docs/get-started/docker/](https://www.adsb.lol/docs/get-started/docker/)
## Bare metal install

If you are looking for a script to run on your existing station, [you can see here](https://github.com/adsblol/feed/tree/master).

Works on all images of other flight aggregator companies.

This install will only setup an ADSB+MLAT feed to adsb.lol, without impacting your existing feeds/services.

Run:

```
curl -fsL -o /tmp/adsblol.sh https://adsb.lol/feed.sh && sudo bash /tmp/adsblol.sh
```
## Manual feeding with readsb and mlat-client
1. First generate a UUID: `cat /proc/sys/kernel/random/uuid`
2. Add this to your wiedehopf readsb: `--net-connector feed.adsb.lol,30004,beast_reduce_plus_out,in.adsb.lol,1337,uuid=UUID` be sure to replace UUID with your uuid.
3. not sure what you need for mlat-client

## Thank you SDR-Enthusiasts!

This would not be possible without [SDR-Enthusiasts](https://github.com/sdr-enthusiasts/) who have made [the original docker-compose](https://github.com/sdr-enthusiasts/docker-install) file.

This repo is largely based off of their work plus some command line interface tools to make running the stack a bit simpler.

[Their documentation can be very useful in enabling extra feeders.](https://sdr-enthusiasts.gitbook.io/ads-b/feeder-containers/feeding-flightaware-piaware).
