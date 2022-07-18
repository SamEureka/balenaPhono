#/bin/bash

## balenaPhono/start.sh ##
## Sam Dennon//2021     ##

# Build the config files
python3 phonoConfig.py

echo "Copying icecast2 service and config"
cp icecast2 /etc/default/
cp icecast.xml /etc/icecast2/

echo "Starting the Icecast2 service"
service icecast2 start
sleep 2

## You may need to change this to /proc/asound/card1 ##
until [ -d /proc/asound/card0 ]
do
  echo "Waiting for USB sound device"
  sleep 5
done

echo "USB device detected, starting Darkice stream"
darkice -c ./darkice.cfg
