#!/usr/bin/env python

## balenaPhono/booter.py ##
## Sam Dennon // 2023    ##

import os
import requests
from dotenv import load_dotenv
from pathlib import Path


dotenv_path = Path('/balenaPhono/.env')
load_dotenv(dotenv_path=dotenv_path)

# Get some stuff from env
BALENA_SUPERVISOR_ADDRESS = os.environ['BALENA_SUPERVISOR_ADDRESS']
BALENA_SUPERVISOR_API_KEY = os.environ['BALENA_SUPERVISOR_API_KEY']

# POST variables
URL = f"{BALENA_SUPERVISOR_ADDRESS}/v1/reboot?apikey={BALENA_SUPERVISOR_API_KEY}"
HEADERS = {"Content-Type": "application/json"}

# Send the reboot signal to the BALENA SUPERVISOR
requests.post(URL, headers=HEADERS)
