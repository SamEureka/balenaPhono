## balenaPhono 
### A turntable phono/AUX/USB network streamer

#### Device Variables
| Variable | Example Value | Note |
|---|---|---|
| CHECK_CONN_FREQ | 120 | This is the wifi-connect polling wait time in seconds. The default is 120 seconds, I usually set mine to 3000.  |
| REBOOT_SLEEP_TIME | 1d | Default is 1d (one day). Will work with d m s (days, minutes, seconds) This the sleep time for the balenaBooter. Darkcast audio streams have a tendency to get corrupted after a few days of up time. balenaBooter reboots the host once a day to keep things clean. Looking for a better way... if you have ideas. |

#### Credits:
* https://forums.balena.io/t/reboot-balenasound-with-cron/297717/8
* https://github.com/niedfelj/balena-rpi-audio-streaming
* https://www.instructables.com/id/Add-Aux-to-Sonos-Using-Raspberry-Pi/



