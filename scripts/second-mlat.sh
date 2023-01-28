#!/bin/bash
SERVICE="/lib/systemd/system/adsblol-mlat2.service"

if [[ -z ${1} ]]; then
    echo --------------
    echo ERROR: requires a parameter
    exit 1
fi

cat >"$SERVICE" <<"EOF"
[Unit]
Description=adsblol-mlat2
Wants=network.target
After=network.target

[Service]
User=adsblol
EnvironmentFile=/etc/default/adsblol
ExecStart=/usr/local/share/adsblol/venv/bin/mlat-client \
    --input-type $INPUT_TYPE --no-udp \
    --input-connect $INPUT \
    --server feed.adsb.lol:SERVERPORT \
    --user $USER \
    --lat $LATITUDE \
    --lon $LONGITUDE \
    --alt $ALTITUDE \
    $UUID_FILE \
    $PRIVACY \
    $RESULTS
Type=simple
Restart=always
RestartSec=30
StartLimitInterval=1
StartLimitBurst=100
SyslogIdentifier=adsblol-mlat2
Nice=-1

[Install]
WantedBy=default.target
EOF

if [[ -f /boot/adsb-config.txt ]]; then
    sed -i -e 's#EnvironmentFile.*#EnvironmentFile=/boot/adsblol-env\nEnvironmentFile=/boot/adsb-config.txt#' "$SERVICE"
fi

sed -i -e "s/SERVERPORT/${1}/" "$SERVICE"
if [[ -n ${2} ]]; then
    sed -i -e "s/\$RESULTS/${2}/" "$SERVICE"
fi

systemctl enable adsblol-mlat2
systemctl restart adsblol-mlat2
