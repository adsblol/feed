# adsb.lol feed

This repo holds the code for the feed client.

The feed client runs on containerd, a high performance container runtime.

ARMv7, ARM64 and AMD64 architectures are all supported.

## Usage

By default, the client will feed to adsb.lol.

To see the current list of supported aggregators, see the [services.txt](services.txt) file.

If you have an issue with the feed client, please [paste.ee](https://paste.ee) your error logs join our chat on [matrix](https://matrix.to/#/#adsblol:gatto.club) or [discord](https://adsb.lol/discord).

## Installation

1. You should be root during this process. You can switch user to root with `sudo su`.

2. First, ensure your system is up to date.
```
apt-get update
apt-get upgrade
```

3. Then, clone this repository.

```
mkdir /opt/adsblol
git clone https://github.com/adsblol/feed /opt/adsblol
cd /opt/adsblol
```

4. Install dependencies.

```
bin/adsblol-init
```

5. Configure the environment variables
```
nano .env
```

6. Generate the config and run
```
bin/gen; nerdctl compose rm -f; nerdctl compose up -d
```

We are up!

See http://IP:8080/ to confirm that tar1090 is working.

See https://adsb.lol to see that you are feeding.

Does it take a while to show up? [You can ask in our Discord for assistance.](https://adsb.lol/discord)

## Feeding to other aggregators

The feed client can be configured to feed to other aggregators.

For other community aggregators such as adsb.one, edit these lines in the `docker-compose.yml` file:

```
    environment:
      - READSB_NET_CONNECTOR=readsb,30105,beast_in;feed.adsb.lol,30004,beast_out;feed.adsb.one,64004,beast_out
      - MLAT_CONFIG=feed.adsb.lol,1338;feed.adsb.one,64006
```

If you want to feed to other aggregators, you will need to edit the `services.txt` file.

To do this, open the `services.txt` file and enable the aggregator by uncommenting it.

You may have to define further environment variables in the `.env` file.

Then, run `bin/gen` to generate the new config, `nerdctl compose rm -f` to remove the old containers, and `nerdctl compose up -d` to start the new containers.

## Troubleshooting

### Logs
- `nerdctl logs readsb` - readsb logs
- `nerdctl logs adsblol` - adsblol logs
- `nerdctl logs tar1090` - mlat logs

### Reset repo
- `git fetch --all` - fetch latest commits
- `git reset --hard origin/hard` - reset to latest commit
