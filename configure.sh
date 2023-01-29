#!/bin/bash

#####################################################################################
#                        adsb.lol SETUP SCRIPT                                #
#####################################################################################
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                                                                   #
# Copyright (c) 2020 ADSBx                                                          #
#                                                                                   #
# Permission is hereby granted, free of charge, to any person obtaining a copy      #
# of this software and associated documentation files (the "Software"), to deal     #
# in the Software without restriction, including without limitation the rights      #
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell         #
# copies of the Software, and to permit persons to whom the Software is             #
# furnished to do so, subject to the following conditions:                          #
#                                                                                   #
# The above copyright notice and this permission notice shall be included in all    #
# copies or substantial portions of the Software.                                   #
#                                                                                   #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR        #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,          #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE       #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER            #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,     #
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE     #
# SOFTWARE.                                                                         #
#                                                                                   #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

set -e
trap 'echo "[ERROR] Error in line $LINENO when executing: $BASH_COMMAND"' ERR
renice 10 $$ &>/dev/null

IPATH=/usr/local/share/adsblol

function abort() {
    echo ------------
    echo "Setup canceled (probably using Esc button)!"
    echo "Please re-run this setup if this wasn't your intention."
    echo ------------
    exit 1
}

## WHIPTAIL DIALOGS

BACKTITLETEXT="adsb.lol Setup Script"

whiptail --backtitle "$BACKTITLETEXT" --title "$BACKTITLETEXT" --yesno "Thanks for choosing to share your data with adsb.lol!\n\nadsb.lol is a co-op of ADS-B/Mode S/MLAT feeders from around the world. This script will configure your current your ADS-B receiver to share your feeders data with adsb.lol.\n\nWould you like to continue setup?" 13 78 || abort

adsblolUSERNAME=$(whiptail --backtitle "$BACKTITLETEXT" --title "Feeder MLAT Name" --nocancel --inputbox "\nPlease enter a unique name to be shown on the MLAT map (the pin will be offset for privacy)\n\nExample: \"william34-london\", \"william34-jersey\", etc.\nDisable MLAT: enter a zero: 0" 12 78 3>&1 1>&2 2>&3) || abort

NOSPACENAME="$(echo -n -e "${adsblolUSERNAME}" | tr -c '[a-zA-Z0-9]_\- ' '_')"

if [[ "$NOSPACENAME" != 0 ]]; then
    whiptail --backtitle "$BACKTITLETEXT" --title "$BACKTITLETEXT" \
        --msgbox "For MLAT the precise location of your antenna is required.\
        \n\nA small error of 15m/45ft will cause issues with MLAT!\
        \n\nTo get your location, use any online map service or this website: https://www.mapcoordinates.net/en" 12 78 || abort
else
    whiptail --backtitle "$BACKTITLETEXT" --title "$BACKTITLETEXT" \
        --msgbox "MLAT DISABLED!.\
        \n\n For some local functions the approximate receiver location is still useful, it won't be sent to the server." 12 78 || abort
fi

#((-90 <= RECEIVERLATITUDE <= 90))
LAT_OK=0
until [ $LAT_OK -eq 1 ]; do
    RECEIVERLATITUDE=$(whiptail --backtitle "$BACKTITLETEXT" --title "Receiver Latitude ${RECEIVERLATITUDE}" --nocancel --inputbox "\nEnter your receivers precise latitude in degrees with 5 decimal places.\n(Example: 32.36291)" 12 78 3>&1 1>&2 2>&3) || abort
    LAT_OK=`awk -v LAT="$RECEIVERLATITUDE" 'BEGIN {printf (LAT<90 && LAT>-90 ? "1" : "0")}'`
done


#((-180<= RECEIVERLONGITUDE <= 180))
LON_OK=0
until [ $LON_OK -eq 1 ]; do
    RECEIVERLONGITUDE=$(whiptail --backtitle "$BACKTITLETEXT" --title "Receiver Longitude ${RECEIVERLONGITUDE}" --nocancel --inputbox "\nEnter your receivers longitude in degrees with 5 decimal places.\n(Example: -64.71492)" 12 78 3>&1 1>&2 2>&3) || abort
    LON_OK=`awk -v LON="$RECEIVERLONGITUDE" 'BEGIN {printf (LON<180 && LON>-180 ? "1" : "0")}'`
done

ALT=0
until [[ "$NOSPACENAME" == 0 ]] || [[ $ALT =~ ^(-?[0-9]*)ft$ ]] || [[ $ALT =~ ^(-?[0-9]*)m$ ]]; do
    ALT=$(whiptail --backtitle "$BACKTITLETEXT" --title "Altitude above sea level (at the antenna):" \
        --nocancel --inputbox \
"\nEnter your receivers altitude above sea level including the unit, no spaces:\n\n\
in feet like this:                   255ft\n\
or in meters like this:               78m\n" \
        12 78 3>&1 1>&2 2>&3) || abort
done

if [[ $ALT =~ ^-(.*)ft$ ]]; then
        NUM=${BASH_REMATCH[1]}
        NEW_ALT=`echo "$NUM" "3.28" | awk '{printf "-%0.2f", $1 / $2 }'`
        ALT=$NEW_ALT
fi
if [[ $ALT =~ ^-(.*)m$ ]]; then
        NEW_ALT="-${BASH_REMATCH[1]}"
        ALT=$NEW_ALT
fi

RECEIVERALTITUDE="$ALT"

#RECEIVERPORT=$(whiptail --backtitle "$BACKTITLETEXT" --title "Receiver Feed Port" --nocancel --inputbox "\nChange only if you were assigned a custom feed port.\nFor most all users it is required this port remain set to port 30005." 10 78 "30005" 3>&1 1>&2 2>&3)



INPUT="127.0.0.1:30005"
INPUT_TYPE="dump1090"

if [[ $(hostname) == "radarcape" ]] || pgrep rcd &>/dev/null; then
    INPUT="127.0.0.1:10003"
    INPUT_TYPE="radarcape_gps"
fi

function writeMlatService() {
tee /lib/systemd/system/adsblol-mlat-$1.service << EOF
[Unit]
Description=adsblol-mlat-${1}
Wants=network.target
After=network.target

[Service]
User=adsblol
ExecStart=/usr/local/share/adsb-one/adsblol-mlat-${1}.sh
Type=simple
Restart=always
RestartSec=30
StartLimitInterval=1
StartLimitBurst=100
SyslogIdentifier=adsblol-mlat-${1}
Nice=-1

[Install]
WantedBy=default.target

EOF
}

function writeMlatSh() {
INPUT_IP=$(echo $2 | cut -d: -f1)
INPUT_PORT=$(echo $2 | cut -d: -f2)
tee /usr/local/share/adsb-one/adsblol-mlat-$1.sh > /dev/null << EOF
if grep -qs -e 'LATITUDE' /boot/adsblol-config.txt &>/dev/null && [[ -f /boot/adsblol-env ]]; then
    source /boot/adsblol-config.txt
    source /boot/adsblol-env
else
    source /etc/default/adsblol
fi

if [[ "$LATITUDE" == 0 ]] || [[ "$LONGITUDE" == 0 ]] || [[ "$USER" == 0 ]] || [[ "$USER" == "disable" ]]; then
    echo MLAT DISABLED
    sleep 3600
    exit
fi

INPUT_IP=$INPUT_IP
INPUT_PORT=$INPUT_PORT

sleep 2

while ! nc -z $INPUT_IP $INPUT_PORT && command -v nc &>/dev/null; do
    echo "Could not connect to $INPUT_IP:$INPUT_PORT, retry in 10 seconds."
    sleep 10
done

exec /usr/local/share/adsblol/venv/bin/mlat-client \
    --input-type "$INPUT_TYPE" --no-udp \
    --input-connect "$INPUT" \
    --server "$2" \
    --user "$USER" \
    --lat "$LATITUDE" \
    --lon "$LONGITUDE" \
    --alt "$ALTITUDE" \
    $PRIVACY \
    $UUID_FILE \
    $RESULTS $RESULTS1 $RESULTS2 $RESULTS3 $RESULTS4
EOF
}

additional_feeds=$(whiptail --separate-output --checklist "Choose options" 10 35 5 \
    --title "Select additional feeds" \
    "1" "adsb.one" ON \
    "2" "adsb.fi" ON 3>&1 1>&2 2>&3)
if [ -z "$additional_feeds" ]; then
  echo "No additional feeds selected"
else
  for feed in $additional_feeds; do
    case "$feed" in
    "1")
      TARGET="$TARGET --net-connector=feed.adsb.one,30004,beast_reduce_out"
      ;;
    "2")
      TARGET="$TARGET --net-connector=feed.adsb.fi,64004,beast_reduce_out"
      ;;
    esac
  done
fi

custom_feeds=$(whiptail --inputbox "Enter custom feeder urls in a comma separated list of host:port.\nExample: feed.example.com:30005." 10 100 3>&1 1>&2 2>&3)
if [ -z "$custom_feeds" ]; then
  echo "No custom feeds selected"
else
  for i in $(echo $custom_feeds | tr "," " "); do
    host=$(echo $i | awk -F ":" '{print $1}')
    port=$(echo $i | awk -F ":" '{print $2}')
    TARGET="$TARGET --net-connector=$host,$port,beast_reduce_out"
  done
fi

additional_mlat=$(whiptail --separate-output --checklist "Choose options" 10 35 5 \
  --title "Select additional MLAT feeds" \
  "1" "adsb.one" ON \
  "2" "adsb.fi" ON 3>&1 1>&2 2>&3)
if [ -z "$additional_mlat" ]; then
  echo "No additional mlat feeds selected"
else
  for mlat in $additional_mlat; do
    case "$mlat" in
    "1")
      writeMlatService "adsb-one"
      writeMlatSh "adsb-one" "adsb.one:64006"
      ;;
    "2")
      writeMlatService "adsb-fi"
      writeMlatSh "adsb-fi" "adsb.fi:30105"
      ;;
    esac
  done
fi

tee /etc/default/adsblol >/dev/null <<EOF
INPUT="$INPUT"
REDUCE_INTERVAL="0.5"

# feed name for checking MLAT sync 
# also displayed on the MLAT map
USER="$NOSPACENAME"

LATITUDE="$RECEIVERLATITUDE"
LONGITUDE="$RECEIVERLONGITUDE"

ALTITUDE="$RECEIVERALTITUDE"

# this is the source for 978 data, use port 30978 from dump978 --raw-port
# if you're not receiving 978, don't worry about it, not doing any harm!
UAT_INPUT="127.0.0.1:30978"

RESULTS="--results beast,connect,127.0.0.1:30104"
RESULTS2="--results basestation,listen,31420"
RESULTS3="--results beast,listen,30157"
RESULTS4="--results beast,connect,127.0.0.1:30421"
# add --privacy between the quotes below to disable having the feed name shown on the mlat map
# (position is never shown accurately no matter the settings)
PRIVACY=""
INPUT_TYPE="$INPUT_TYPE"

MLATSERVER="feed.adsb.lol:31090"
TARGET="--net-connector feed.adsb.lol,30004,beast_reduce_out,feed.adsb.lol,1337 $TARGET"
NET_OPTIONS="--net-heartbeat 60 --net-ro-size 1280 --net-ro-interval 0.2 --net-ro-port 0 --net-sbs-port 0 --net-bi-port 31421 --net-bo-port 0 --net-ri-port 0 --write-json-every 1"
JSON_OPTIONS="--max-range 450 --json-location-accuracy 2 --range-outline-hours 24"
EOF

