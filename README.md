# <img src="logo.png" alt="turntable image" width="60" /> balenaPhono
## A turntable phono/AUX/USB network streamer

balenaPhono is a project for Raspberry Pi that takes the audio output from a turntable or any other audio device and creates a shoutcast/icecast network stream. This project is great for anyone looking for a cheap and simple way to play vinyl on [Sonos](https://www.sonos.com/en-us/home) or [Ikea Symfonisk](https://www.ikea.com/us/en/cat/wi-fi-speakers-46194/) speakers.

### _*UPDATE! 1/3/2024*_:
* There are breaking changes.
* The stream mount point is now named phono.mp3 by default. You can change it by setting `DARKICE_MOUNT_POINT` and `ICECAST_MOUNT_POINT` to 'your-cool-mount.mp3'. __Existing Sonos Stations and browser bookmarks will need to be updated.__
* I have updated the startup script. It will now attempt to discover your USB Audio device and set the `DARKICE_DEVICE` variable. The detection logic is not :100: accurate, you may need to adjust.
* The rough flow of the detection is: Look for a USB Audio Device (and ignore HDMI Audio), then find the card and device numbers, create the device slug from the discovered numbers. If the variable is already set and matches the detected device the stream will start. If the detection is flawed you can create a `BYPASS_DEVICE_CHECK` variable and then set `DARKICE_DEVICE` manually.

---
### Equipment needed:
* Raspberry Pi (Tested with Pi3, running daily on Pi Zero W)
* Audio device:  
  1. Turntable with USB output -or-
  2. Turntable with RCA output and [USB Phono Preamp](https://www.amazon.com/s?k=usb+phono+preamp)
  3. You can use a [USB audio capture card](https://www.amazon.com/s?k=usb+audio+capture+card) if you want to connect your old Walkman or Diskman.
* A cheaper [USB phono preamp](https://www.amazon.com/gp/product/B002GHBYZ0)
* The turntable I use: audio-technica [AT-LP60XUSB](https://www.audio-technica.com/en-us/turntables/best-for/new-to-vinyl/at-lp60xusb)

---
### Installation INstructions
#### One click install: 
Running this project is as simple as deploying it to a balenaCloud application. You can deploy it in one click by using the button below:

[![balena deploy button](https://www.balena.io/deploy.svg)](https://dashboard.balena-cloud.com/deploy?repoUrl=https://github.com/SamEureka/balenaPhono)

#### Balena Deploy method:
1. Ensure you have git and the balena-cli installed and logged into balenaCloud ([INSTRUCTIONS HERE](https://docs.balena.io/learn/getting-started/raspberry-pi/python/#install-the-balena-cli))

2. Follow these steps to create a fleet. The steps here are generic, change as appropriate for your hardware. ([INSTRUCTIONS HERE](https://docs.balena.io/learn/getting-started/raspberry-pi/python/#create-a-fleet))

4. Add a new device to your fleet and provision your hardware using balenaEtcher or similar software. ([INSTRUCTIONS HERE](https://docs.balena.io/learn/getting-started/raspberry-pi/python/#add-a-device-and-download-os))

5. Clone this repo `git clone https://github.com/SamEureka/balenaPhono.git`

6. Change into the balenaPhono directory `cd balenaPhono`

7. Use balena push command to build and upload the container image to your device. `balena push <name of your fleet>` (example, my fleet is called 'balenaPhonoDev' `balena push balenaPhonoDev`)

8. Wait for Charlie Unicorn to appear!

---
### Post install setup:
1. The balenaPhono startup script will attempt to discover your sound device and set it automagicaly. 


   __If the detection fails you may need to bypass the detection and set the DARKICE_DEVICE variable to match your device.__ 
    
    - Create a `BYPASS_DEVICE_CHECK` device variable and set it to `true`
    - Create a `DARKICE_DEVICE` device variable and set it to match your hardware. Take a look [here](http://manpages.ubuntu.com/manpages/bionic/man5/darkice.cfg.5.html) for troubleshooting tips. 

2. Get the local ip address for your device from the balenaCloud console.

3. To play the stream in a browser window:

    ```
    http://<device-ip>/phono.mp3
    ```

4. To add your phono stream to your Sonos system:

    #### Using the iPhone or Android app 
    1.  Download the Sonos App. [Sonos Downloads](https://support.sonos.com/en-us/downloads) (Tested with Sonos S1 Controller App)
    
    2. Tap into - Browse > TuneIn > My Radio Stations

    3. On the My Radio Stations page tap the top `...` and then tap `Add New Radio Station`

    4. In the 'Streaming URL' field enter `http://<device-ip>/phono.mp3` and in the 'Station Name' field enter `balenaPhono` then tap 'OK' 

    #### Using the Unofficial Sonos Controller For Linux
    1. From the menu bar select - Player > Play URL

    2. Enter `http://<device-ip>/phono.mp3` in the field and click 'OK'

### Additional setup (not required)

  #### Balena Booter
  - Use the `REBOOT_TIME` variable to specify the hour of the day you would like balenaPhono to reboot. This keeps the darkice stream from becoming unstable over time. Acceptable values are 0 through 23 representing the hour you want the device to reboot every day. 

---
### Available Device Variables:
##### For advanced configuration
| Variable | Example Value | Note |
|---|---|---|
| BYPASS_DEVICE_CHECK | true | To bypass the automagical DARKICE_DEVICE setup, set this variable to `true` (be sure to also set DARKICE_DEVICE to match your audio hardware.) | 
| PORTAL_SSID | balenaPhono | Wifi-connect captive portal SSID **Check out [wifi-connect](https://github.com/balenablocks/wifi-connect) page for additional variables. |
| PORTAL_PASSPHRASE | balenaPhono | Wifi-connect captive portal Passphrase |
| PORTAL_LISTENING_PORT | 8000 | Port the darkice stream is sent to. *Changed from the default port 80 due to conflict with Icecast server |
| CHECK_CONN_FREQ | 120 | This is the wifi-connect polling wait time in seconds. The default is 120 seconds, I usually set mine to 3000.  |
| REBOOT_TIME | 4 | Default is 4 (reboot every 24 hours at [4:00am](https://github.com/SamEureka/balenaPhono/issues/5) in the `America/Los_Angeles` timezone). Acceptable values are 0 through 23 representing the hour you want the device to reboot every day. Darkice audio streams have a tendency to get corrupted after a few days of up time. A python script triggered by cron reboots the host once a day to keep things clean. Looking for a better way... if you have ideas. |
| TZ | `America/Los_Angeles` | Sets the timezone. Look up your timezone [here](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List). Default is `America/Los_Angeles` |
| ICECAST_LOCATION | Interwebs | Where your stream is hosted from or where you are located. |
| ICECAST_ADMIN_EMAIL | balenaAdmin@localhost | Used for the Icecast status page, doesn't need to be real |
| ICECAST_CLIENTS | 10 | How many clients can connect to your stream. Keep it low if you are using a Pi Zero |
| ICECAST_SOURCE_PASSWORD | b@13n4! | Password used by Darkice to connect to Icecast. Must be the same as DARKICE_PASSWORD |
| ICECAST_RELAY_PASSWORD | b@13n4! | Not exactly sure what this one is for. You can change it with this device variable! |
| ICECAST_ADMIN_NAME | balenaAdmin | Username for logging into the admin portal. |
| ICECAST_ADMIN_PASSWORD | b@13n4-@dm1n! | Password for the admin portal |
| ICECAST_HOSTNAME | balenaPhono | Hostname for the Icecast server |
| ICECAST_PORT | 80 | Port that Icecast server listens on. Needs to be the same as DARKICE_PORT |
| ICECAST_MOUNT_POINT | phono.mp3 | Should end in .mp3 for MP3 streams and .ogg for Ogg Vorbis encoding |
| ICECAST_STREAM_NAME | balenaPhono | Name of your stream. |
| ICECAST_STREAM_DESC | A stream from AUX/Phono | Description of your stream. |
| ICECAST_GENRE | Vinyl | The genre of your stream. |
| DARKICE_DURATION | 0 | Duration of the stream in seconds. Set this to 0 to disable. |
| DARKICE_BUFFER_SECONDS | 1 | How many seconds the stream buffers before playing. Minimum value: 1 (seems to work fine) |
| DARKICE_RECONNECT | yes | Automatically re-connect to Icecast |
| DARKICE_DEVICE | plughw:0,0 | Source device for your stream. Very hard to find information on this setting. Try this [man page](http://manpages.ubuntu.com/manpages/bionic/man5/darkice.cfg.5.html). The default setting here worked on a pi zero w. On a pi3 I had to change it to plughw:1,0 Good Luck! |
| DARKICE_SAMPLE_RATE | 44100 | Sample rate of the source audio. You shouldn't need to change this. |
| DARKICE_BITS_PER_SAMPLE | 16 | Bits per sample. You shouldn't need to change this one either. |
| DARKICE_CHANNEL | 2 | How many channels. 2 for stereo... 1 for mono |
| DARKICE_BITRATE_MODE | cbr | Accepts cbr, abr, vbr. Read the [man page](http://manpages.ubuntu.com/manpages/bionic/man5/darkice.cfg.5.html) for more info |
| DARKICE_FORMAT | mp3 | Format of the stream sent to the IceCast2 server. Supported formats  are  'vorbis', 'opus', 'mp3', 'mp2', 'aac' and 'aacp' |
| DARKICE_BITRATE | 320 | Bit rate to encode to in kBits / sec (e.g. 320). Only used when cbr or abr bitrate modes are specified. |
| DARKICE_SERVER | localhost | Icecast server address or url |
| DARKICE_PORT | 80 | Icecast port. Needs to be the same as ICECAST_PORT |
| DARKICE_PASSWORD | b@13n4! | Needs to be the same as ICECAST_SOURCE_PASSWORD |
| DARKICE_MOUNT_POINT | phono.mp3 | Needs to be the same as ICECAST_MOUNT_POINT |
| DARKICE_NAME | balenaPhono | Name of the stream. |
| | | |


### Getting Help
* Google is your friend!
* Submit an issue on this repo and I'll help if I can.
---
### Reference:
* [Darkice man page](http://manpages.ubuntu.com/manpages/bionic/man5/darkice.cfg.5.html)
* [Darkice REPO](https://github.com/rafael2k/darkice)
* [Darkice Homepage](http://www.darkice.org/)
* [Icecast Homepage](https://icecast.org/)
* [BalenaBlocks/wifi-connect](https://github.com/balenablocks/wifi-connect)
---
### Credits:
* https://forums.balena.io/t/reboot-balenasound-with-cron/297717/8
* https://github.com/niedfelj/balena-rpi-audio-streaming
* https://www.instructables.com/id/Add-Aux-to-Sonos-Using-Raspberry-Pi/
* Icon made by [Freepik](https://www.freepik.com "Freepik") from [www.flaticon.com](https://www.flaticon.com/ "Flaticon")


