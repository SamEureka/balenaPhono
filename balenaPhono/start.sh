#!/bin/bash

## balenaPhono/start.sh ##
## Sam Dennon//2023     ##

# Build the config files
python3 phonoConfig.py
echo "Config files complete"

echo "Copying icecast2 service and config"
cp icecast2 /etc/default/
cp icecast.xml /etc/icecast2/

echo "Starting the Icecast2 service"
service icecast2 start
sleep 2

# Check if DARKICE_DEVICE is set
if [ -n "$DARKICE_DEVICE" ]; then
  echo "Using DARKICE_DEVICE environment variable: $DARKICE_DEVICE"
  darkice -c ./darkice.cfg
else
  # Find the USB sound card dynamically, excluding HDMI sound cards
  usb_card=""
  until [ -n "$usb_card" ]; do
    # Get the list of audio devices using aplay -l, excluding HDMI devices
    usb_card=$(aplay -l | grep -Eo 'card [0-9]+: .*USB.*' | grep -v 'HDMI')

    # Check if any USB Audio Devices are found
    if [ -n "$usb_card" ]; then
      # Extract card and device numbers
      card_number=$(echo "$usb_card" | awk '{print $2}' | tr -d ':')
      device_number=$(echo "$usb_card" | grep -oP 'device \K[0-9]+')

      # Print a message for the user
      echo "**"
      echo "** USB sound device detected: plughw:$card_number,$device_number"
      echo "** Please set the DARKICE_DEVICE Device Variable to plughw:$card_number,$device_number"
      echo "** The device detection is best effort, you may need to"
      echo "** adjust the card and device numbers to match your"
      echo "** hardware configuration. e.g... plughw:0,0 or plughw:1,3"
      echo "** the first number is the card and the second is the device"
      echo "**"
      echo "** Once set, the Darkice stream will start automatically!"
      echo "**" 
      sleep 5
    else
      echo "Waiting for USB sound device, plug your USB Audio device in"
      sleep 5
    fi
  done

  # Wait until DARKICE_DEVICE is set by the user
  until [ -n "$DARKICE_DEVICE" ]; do
    echo "Please set the DARKICE_DEVICE Device Variable to plughw:$card_number,$device_number"
    sleep 5
  done

  echo "USB sound device detected, starting Darkice stream with DARKICE_DEVICE: $DARKICE_DEVICE"
  darkice -c ./darkice.cfg
fi