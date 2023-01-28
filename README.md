# adsb.lol feed client

ADSB.lol is an [open source](https://github.com/adsblol/infra) ADSB+MLAT aggregator.


- These scripts aid in setting up your current ADS-B receiver to feed adsb.lol.
- They will not disrupt any existing feed clients already present

## 1: Find coordinates / elevation:

<https://www.freemaptools.com/elevation-finder.htm>

## 2: Install the adsblol feed client

```
curl -L -o /tmp/axfeed.sh https://raw.githubusercontent.com/adsblol/feed/master/install.sh
sudo bash /tmp/axfeed.sh
```

## 3: Check netstat to check if your feed is working

The feed IP for adsb.lol is currently 142.132.241.63

```
$ host feed.adsb.lol
feed.adsb.lol has address 142.132.241.63
```

Expected Output:
```
$ netstat -t -n | grep -E '30004|31090'
tcp        0    182 localhost:43530     65.109.2.208:31090      ESTABLISHED
tcp        0    410 localhost:47332     65.109.2.208:30004      ESTABLISHED
```

## 4: Optional: Install the stats package for an online map that shows only planes received by you:

```
curl -L -o /tmp/axstats.sh https://raw.githubusercontent.com/adsblol/feed/master/stats.sh
sudo bash /tmp/axstats.sh

adsblol-showurl
```

### Optional: local interface for your data http://192.168.X.XX/adsblol

Install / Update:
```
sudo bash /usr/local/share/adsblol/git/install-or-update-interface.sh
```
Remove:
```
sudo bash /usr/local/share/tar1090/uninstall.sh adsblol
```

### Update the feed client without reconfiguring

```
curl -L -o /tmp/axupdate.sh https://raw.githubusercontent.com/adsblol/feed/master/update.sh
sudo bash /tmp/axupdate.sh
```


### If you encounter issues, please do a reboot and then supply these logs on the forum (last 20 lines for each is sufficient):

```
sudo journalctl -u adsblol-feed --no-pager
sudo journalctl -u adsblol-mlat --no-pager
```


### Display the configuration

```
cat /etc/default/adsblol
```

### Changing the configuration

This is the same as the initial installation.
If the client is up to date it should not take as long as the original installation,
otherwise this will also update the client which will take a moment.

```
curl -L -o /tmp/axfeed.sh https://raw.githubusercontent.com/adsblol/feed/master/install.sh
sudo bash /tmp/axfeed.sh
```

### Disable / Enable adsb.lol MLAT-results in your main decoder interface (readsb / dump1090-fa)

- Disable:

```
sudo sed --follow-symlinks -i -e 's/RESULTS=.*/RESULTS=""/' /etc/default/adsblol
sudo systemctl restart adsblol-mlat
```
- Enable:

```
sudo sed --follow-symlinks -i -e 's/RESULTS=.*/RESULTS="--results beast,connect,127.0.0.1:30104"/' /etc/default/adsblol
sudo systemctl restart adsblol-mlat
```

### Restart

```
sudo systemctl restart adsblol-feed
sudo systemctl restart adsblol-mlat
```


### Systemd Status

```
sudo systemctl status adsblol-mlat
sudo systemctl status adsblol-feed
```


### Removal / disabling the services:

```
sudo bash /usr/local/share/adsblol/uninstall.sh
```

If the above doesn't work, you may be using an old version that didn't have the uninstall script, just disable the services and the scripts won't run anymore:

```
sudo systemctl disable --now adsblol-feed
sudo systemctl disable --now adsblol-mlat
```
