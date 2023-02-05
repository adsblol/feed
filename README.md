# adsb.lol / feed


[adsb.lol](https://adsb.lol) is an open-source, community-driven ADS-B / UAT / MLAT feed aggregator.

We are always looking for new contributors. Our code is open source and we welcome pull requests ([See todo](https://adsb.lol/todo))

This includes the [infrastructure](https://github.com/adsblol/infra), [API](https://github.com/adsblol/api) and [history](httprs://github.com/adsblol/history) services.

The adsb.lol feed client is a toolkit that allows you to install, run and maintain a ADS-B / UAT / MLAT / ACARS / VDL2 feed client.

It is built with ease of use in mind. It is designed to be run on a Raspberry Pi, but can be run on any Linux Debian-like system.

## Quick Start
Run this on **as root** a fresh install of Raspberry Pi OS Lite or similar

```
bash <(curl -Ls https://raw.githubusercontent.com/adsblol/feed/main/bin/adsblol-init)
cd /opt/adsblol/
cp .env.example .env
nano .env
```

Then, edit the `.env` file to your liking.

```
adsblol-debug && adsblol-up
```
<http://IP:8080/> to confirm that readsb is working, <http://IP:8082/> to confirm that the adsblol multifeeder is working.

## Usage

By default, the client will feed to adsb.lol.

To see the current list of supported aggregators, see the [services.txt](services.txt) file.

The `adsblol` service supports feeding to multiple aggregators.

If you have an issue with the feed client, please [paste.ee](https://paste.ee) your error logs join our chat on [matrix](https://matrix.to/#/#adsblol:gatto.club) or [discord](https://adsb.lol/discord).

## Feeding to other aggregators

The `adsblol` service can feed to other aggregators.

To feed <https://adsb.one> and <https://theairtraffic.com>, two community aggregators we actively work with to share data, follow these steps.

Run:
```
adsblol-env set READSB_ADDITIONAL_NET_CONNECTOR feed.adsb.one,64004,beast_reduce_out;feed.theairtraffic.com,30004,beast_reduce_out
adsblol-env set ADSBLOL_ADDITIONAL_MLAT_CONFIG feed.adsb.adsb.one,64006,39001;feed.theairtraffic.com,31090,39002
adsblol-env set MLAT_MLATHUB_NET_CONNECTOR adsblol,39000,beast_in;adsblol,39001,beast_in;adsblol,39002,beast_in
```
Then, restart the stack
```
adsblol-up
```

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

### Logs

- `adsblol-logs` - view logs
- `adsblol-logs -f` - view logs and follow

### Services
- `adsblol-service enable <service>` - enable a service
- `adsblol-service disable <service>` - disable a service
- `adsblol-service list` - list all enabled services

### Environment
- `adsblol-env list` - list all environment variables
- `adsblol-env set <key>` - set an environment variable

### SDR
- `adsblol-sdr test` - Runs rtl_test
- `adsblol-sdr dockertest` - Runs rtl_test in a docker container
- `adsblol-sdr dockerppm` - Runs rtl_test in a docker container with the intent to estimate the PPM

### Reset
- `adsblol-reset` - reset the /opt/adsblol directory
