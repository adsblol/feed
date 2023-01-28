#!/bin/bash
set -x

IPATH=/usr/local/share/adsblol

systemctl disable --now adsblol-mlat
systemctl disable --now adsblol-mlat2 &>/dev/null
systemctl disable --now adsblol-feed

if [[ -d /usr/local/share/tar1090/html-adsblol ]]; then
    bash /usr/local/share/tar1090/uninstall.sh adsblol
fi

rm -f /lib/systemd/system/adsblol-mlat.service
rm -f /lib/systemd/system/adsblol-mlat2.service
rm -f /lib/systemd/system/adsblol-feed.service

cp -f "$IPATH/adsblol-uuid" /tmp/adsblol-uuid
rm -rf "$IPATH"
mkdir -p "$IPATH"
mv -f /tmp/adsblol-uuid "$IPATH/adsblol-uuid"

set +x

echo -----
echo "adsb.lol feed scripts have been uninstalled!"
