#/bin/bash

echo "Copying icecast2 service and config."
cp icecast2 /etc/default/
cp icecast.xml /etc/icecast2/

service icecast2 start
sleep 2

until [ -d /proc/asound/card1 ]
do
  echo "Waiting for USB sound device."
  sleep 5
done

echo "USB device detected, starting Darkice stream."
darkice -c ./darkice.cfg