# adsb.lol / feed


[adsb.lol](https://adsb.lol) is an open-source, community-driven ADS-B / UAT / MLAT feed aggregator.

We are always looking for new contributors. Our code is open source and we welcome pull requests ([See todo](https://adsb.lol/todo))

This includes the [infrastructure](https://github.com/adsblol/infra), [API](https://github.com/adsblol/api) and [history](https://github.com/adsblol/history) services.

The adsb.lol feed client is a toolkit that allows you to install, run and maintain a ADS-B / UAT / MLAT / ACARS / VDL2 feed client.

It is built with ease of use in mind. It is designed to be run on a Raspberry Pi, but can be run on any Linux Debian-like system.

## Quick Start
Run this **as root** on a fresh install of Raspberry Pi OS Lite or similar

```
bash <(curl -Ls https://raw.githubusercontent.com/adsblol/feed/main/bin/adsblol-init)
cd /opt/adsblol/
cp .env.example .env
```

Then, set the environment variables.

You can either edit the `.env` file, or run `adsblol-env set <key> <value>`

```
# Altitude in meters
adsblol-env set FEEDER_ALT_M 542
# Latitude
adsblol-env set FEEDER_LAT 98.76543
# Longitude
adsblol-env set FEEDER_LONG 12.34567
# Timezone (see https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)
adsblol-env set FEEDER_TZ America/New_York
# SDR Serial Number
adsblol-env set ADSB_DONGLE_SERIAL 1090
# Site name (shows up on the MLAT map!)
adsblol-env set MLAT_SITE_NAME "My epic site"
# Would you like to appear on map.adsb.lol? Then set this:
adsblol-env unset ADSBLOL_MLAT_CONFIG
```

These are the minimum environment variables you need to set.

Then, run:
```
adsblol-debug && adsblol-up
```
Let's check if everything is working:

- [ ] <http://IP:8080> (readsb)
- [ ] <http://IP:8082> (adsblol)
- [ ] <https://adsb.lol> (ADSB)
- [ ] <https://map.adsb.lol> (MLAT)

## Usage

By default, the client will feed to adsb.lol.

To see the current list of supported aggregators, see the [services.txt](services.txt) file.

The `adsblol` service supports feeding to multiple aggregators.

If you have an issue with the feed client, please [paste.ee](https://paste.ee) your error logs join our chat on [matrix](https://matrix.to/#/#adsblol:gatto.club) or [discord](https://adsb.lol/discord).

## Feeding to other aggregators

The `adsblol` service can feed to other aggregators.

In this example, we feed [adsb.one](https://adsb.one) and [theairtraffic.com](https://theairtraffic.com),
two community aggregators we actively work with to share data.

### Run

**NOTE:** This is using `--privacy`, which excludes you from adsb.lol map, and should exclude you from other aggregators maps too.

```
adsblol-env set ADSBLOL_ADDITIONAL_NET_CONNECTOR "feed.adsb.one,64004,beast_reduce_out;feed.theairtraffic.com,30004,beast_reduce_out"
adsblol-env set ADSBLOL_ADDITIONAL_MLAT_CONFIG "feed.adsb.one,64006,39001,--privacy;feed.theairtraffic.com,31090,39002,--privacy"
adsblol-env set MLATHUB_NET_CONNECTOR "adsblol,39000,beast_in;adsblol,39001,beast_in;adsblol,39002,beast_in"
```
**If you would like to disable privacy mode, instead, use:**
```
adsblol-env set ADSBLOL_ADDITIONAL_NET_CONNECTOR "feed.adsb.one,64004,beast_reduce_out;feed.theairtraffic.com,30004,beast_reduce_out"
adsblol-env set ADSBLOL_ADDITIONAL_MLAT_CONFIG "feed.adsb.one,64006,39001;feed.theairtraffic.com,31090,39002"
adsblol-env set MLATHUB_NET_CONNECTOR "adsblol,39000,beast_in;adsblol,39001,beast_in;adsblol,39002,beast_in"
```

### Restart the stack

```
adsblol-up
```

You can now check [adsb.one](https://adsb.one/myip) and [theairtraffic.com](https://theairtraffic.com/feed/myip/) to see if your feed is working.

## Enabling a service

To enable a service, run `adsblol-service enable <service>`
To disable a service, run `adsblol-service disable <service>`
This is a helper command that will edit the `services.txt` file, and run `adsblol-gen` to generate a new `cmdline.txt`.

You may have to define further environment variables in the `.env` file.

Then, run `adsblol-gen` to generate a new cmdline.txt.

The cmdline.txt is used by the adsblol binaries to know what services to start.

Once you have done this, run `adsblol-up` to start the containers.

## Troubleshooting

To update, run `adsblol-update`

Running `adsblol-debug` will tell you about common mistakes.

### I cannot find myself on the MLAT Map

adsb.lol enables the `--privacy` flag for your MLAT client by default.
This hides you from the MLAT map.

Do you want to appear on the map? Then run:

```
adsblol-env unset ADSBLOL_MLAT_CONFIG && adsblol-up
```

### Logs

- `adsblol-logs` - view logs
- `adsblol-logs -f` - view logs and follow

### Services
- `adsblol-service enable <service>` - enable a service
- `adsblol-service disable <service>` - disable a service
- `adsblol-service list` - list all enabled services

### Environment
- `adsblol-env list` - list all environment variables
- `adsblol-env set <key>` - set an environment variable (also updates if it already exists)
- `adsblol-env unset <key>` - unset an environment variable

### SDR
- `adsblol-sdr test` - Runs rtl_test
- `adsblol-sdr dockertest` - Runs rtl_test in a docker container
- `adsblol-sdr dockerppm` - Runs rtl_test in a docker container with the intent to estimate the PPM

### Reset
- `adsblol-reset` - reset the /opt/adsblol directory
