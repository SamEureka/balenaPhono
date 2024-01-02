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
    
    echo ""
    echo "** USB Sound Device detected!             **"
    echo "** The startup script will attempt to     **"
    echo "** set the DARKICE_DEVICE Device Variable **"
    echo "** to plughw:$card_number,$device_number  **"
    echo "** If you want to set the DARKICE_DEVICE  **"
    echo "** variable manually, or use the defaults, **"
    echo "** set BYPASS_DEVICE_CHECK to 'true'       **"
    echo ""

    # Check if DARKICE_DEVICE is set and matches the current device
    if [ "$DARKICE_DEVICE" = "plughw:$card_number,$device_number" ]; then
      echo "Using DARKICE_DEVICE environment variable: $DARKICE_DEVICE"
      darkice -c ./darkice.cfg
    elif [ "$BYPASS_DEVICE_CHECK" = "true" ]; then
      echo "Bypassing device check as BYPASS_DEVICE_CHECK is set to true"
      darkice -c ./darkice.cfg
    else
      echo "** USB sound device detected! **"
      echo "Setting DARKICE_DEVICE to plughw:$card_number,$device_number"
      export DARKICE_DEVICE="plughw:$card_number,$device_number"
      # run phonoConfig again
      python3 phonoConfig.py
      darkice -c ./darkice.cfg
    fi
  else
    echo "Waiting for USB sound device, plug your USB Audio device in"
    sleep 5
  fi
done

# Wait until DARKICE_DEVICE is set by the user
until [ -n "$DARKICE_DEVICE" ] || [ "$BYPASS_DEVICE_CHECK" = "true" ]; do
  echo "Please set the DARKICE_DEVICE Device Variable to plughw:$card_number,$device_number or set BYPASS_DEVICE_CHECK to true"
  sleep 5
done