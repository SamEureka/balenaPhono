## balenaPhono/phonoConfig.py ##
## DEC2021 (c) // Sam Dennon  ##

import configparser as CFG
import os
import json
import xml.etree.ElementTree as ET

def load_json_config(filename):
    with open(filename) as f:
        return json.load(f)

def get_balena_variable(name, default=None):
    return os.environ.get(name, default)

def create_config_parser(sections):
    config = CFG.ConfigParser()
    config.optionxform = lambda option: option  # Preserve case sensitivity
    for section in sections:
        config.add_section(section)
    return config

def configure_darkice(darkice_json):
    variables = darkice_json['variables']
    dark_config = create_config_parser([v['section'] for v in variables])

    def set_variable(variable):
        balena_key = variable['balena']
        ini_key = variable['ini']
        section = variable['section']
        default = variable['default']
        value = get_balena_variable(balena_key, default)
        dark_config[section][ini_key] = value

    list(map(set_variable, variables))

    with open('darkice.cfg', 'w') as config_file:
        dark_config.write(config_file)

def configure_icecast(icecast_json, tree):
    variables = icecast_json['variables']

    def set_variable(variable):
        balena_key = variable['balena']
        xml_key = variable['xml']
        default = variable['default']
        value = get_balena_variable(balena_key, default)
        tree.find(xml_key).text = value

    list(map(set_variable, variables))

    tree.write('icecast.xml')

if __name__ == '__main__':
    darkice_vars = load_json_config('darkice.json')
    icecast_vars = load_json_config('icecast.xml')

    tree = ET.parse('icecast.xml')

    configure_darkice(darkice_vars)
    configure_icecast(icecast_vars, tree)
