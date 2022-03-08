## balenaPhono/phonoConfig.py ##
## Sam Dennon//DEC2021        ##

import configparser as CFG
import os
import json
import xml.etree.ElementTree as ET

# Checks and writes the Darkice variables to the darkice.cfg file. Pulls from Balena Device variables if they exist.
darkConf = CFG.ConfigParser()
darkConf.optionxform = lambda option: option
with open('darkice.json') as d:
  darkvars = json.load(d)
for sect in darkvars['variables']:
  darksection = sect['section']
  if not darksection in darkConf:
    darkConf[darksection] = {}
def vConf (balena_d,ini_d,section_d,default_d):
  def bConf(balena_d, default_d):
    return os.environ[balena_d] if balena_d in os.environ else default_d
  darkConf[section_d][ini_d] = bConf(balena_d, default_d)
for dark in darkvars['variables']:
  vConf(dark['balena'], dark['ini'], dark['section'], dark['default'])
with open('darkice.cfg', 'w') as config:
  darkConf.write(config)

# Checks and writes the Icecast Variables to the icecast.xml file. Pulls from Balena Device Variables if they exist.
tree = ET.parse('icecast.xml')
icecast = tree.getroot()
with open('icecast.json') as v:
  icevars = json.load(v)
def vCheck(balena_v, xml_v, default_v):
  def bCheck(balena_v, default_v):
    return os.environ[balena_v] if balena_v in os.environ else default_v
  icecast.find(xml_v).text = bCheck(balena_v, default_v)
for ice in icevars['variables']:
  vCheck(ice['balena'],ice['xml'],ice['default'])
tree.write('icecast.xml')
