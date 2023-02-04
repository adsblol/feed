# adsb.lol / feed


[adsb.lol](https://adsb.lol) is an open-source, community-driven ADS-B / UAT / MLAT feed aggregator.

We are always looking for new contributors. Our code is open source and we welcome pull requests ([See todo](https://adsb.lol/todo))

This includes the [infrastructure](https://github.com/adsblol/infra), [API](https://github.com/adsblol/api) and [history](httprs://github.com/adsblol/history) services.

The adsb.lol feed client is a toolkit that allows you to install, run and maintain a ADS-B / UAT / MLAT / ACARS / VDL2 feed client.

It is built with ease of use in mind. It is designed to be run on a Raspberry Pi, but can be run on any Linux Debian-like system.

## Quick Start
Run this on a fresh install of Raspberry Pi OS Lite or similar

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

## Installation

1. You should be root during this process. You can switch user to root with `sudo su`.

```
pi@my-raspberry:~ $ sudo su
root@my-raspberry:~ #

```

2. First, ensure your system is up to date.
```
apt-get update
apt-get upgrade
```

3. Then, run adsblol-init.

```
bash <(curl -Ls https://raw.githubusercontent.com/adsblol/feed/main/bin/adsblol-init)
```

5. Configure the environment variables in /opt/adsblol/.env
```
cp /opt/adsblol/.env.example /opt/adsblol/.env
nano /opt/adsblol/.env
```

6. Let's check that everything is working. Then spin up the containers!
```
adsblol-debug
adsblol-up
```

We are up!

See http://IP:8080/ to confirm that readsb is working, http://IP:8082/ to confirm that the adsblol multifeeder is working.

See <https://adsb.lol> to confirm that you are feeding.

## Feeding to other aggregators

The `adsblol` service can feed to other aggregators, by editing

 `example.com` with BEAST port 30004, mlat port 31090, edit these lines in your `.env` file:

```
MLATHUB_NET_CONNECTOR=adsblol,39000,beast_in
ADSBLOL_NET_CONNECTOR=feed.adsb.lol,30004,beast_out;example.com,30004,beast_out
ASDBLOL_MLAT_CONFIG=feed.adsb.lol,1338,39000
```

If you want to feed to other aggregators, you will need to edit the `services.txt` file.

To do this, open the `services.txt` file and enable the aggregator by uncommenting it.

You may have to define further environment variables in the `.env` file.

Then, run `adsblol-gen` to generate a new cmdline.txt.
The cmdline.txt is used by the adsblol binaries to know what services to start.

Once you have done this, run `adsblol-up` to start the containers.

## Troubleshooting

Running `adsblol-debug` will tell you about common mistakes.

### Logs

- `adsblol-logs` - view logs
- `adsblol-logs -f` - view logs and follow
