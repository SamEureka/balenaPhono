#/bin/bash

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

## You may need to change this to /proc/asound/card1 ##
until [ -d /proc/asound/card0 ]
do
  echo "Waiting for USB sound device"
  sleep 5
done

echo "USB device detected, starting Darkice stream"
darkice -c ./darkice.cfg

# Need to copy the env to a .env file so the booter.py script can access
# the environment variables. I could not figure out a better way to do this.
env >> /balenaPhono/.env
echo "Variables copied to .env"

# Let's update the crond to reboot the system every 24 hours
# at the time specified in the REBOOT_TIME env variable. 
# (defaults to 4am in the timezone specified in the TZ variable.)
REBOOT_TIME="${REBOOT_TIME:=4}"
INCREMENT="${INCREMENT:=0}"
(echo "${INCREMENT} ${REBOOT_TIME} * * * /usr/local/bin/python /balenaPhono/booter.py > /proc/1/fd/1 2>&1") | crontab -
exec cron -f
echo "cron updated"