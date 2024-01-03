#!/usr/bin/env bash

## booter/booter.sh   ##
## 2023 // Sam Dennon ##

# Need to copy the env to a .env file so the booter.py script can access
# the environment variables. I could not figure out a better way to do this.
env >> /booter/.env
echo "Variables copied to .env"

# Let's update the crond to reboot the system every 24 hours
# at the time specified in the REBOOT_TIME env variable. 
# (defaults to 4am in the timezone specified in the TZ variable.)
REBOOT_TIME="${REBOOT_TIME:=4}"
INCREMENT="${INCREMENT:=0}"
(echo "${INCREMENT} ${REBOOT_TIME} * * * /usr/local/bin/python /booter/booter.py > /proc/1/fd/1 2>&1") | crontab -
echo "cron updated"
exec cron -f
