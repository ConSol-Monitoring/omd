#!/usr/bin/env python3
#--------------------------------------------------------------------
# 20200226 mg@consol.de
#--------------------------------------------------------------------
# This scrip controlls creation and deletion of configuration 
# for prometheus snmp_exporter. 
#--------------------------------------------------------------------
# --create write new scrape config
# --delete rm scrape config for host
# --crontab search vor scrape configs older than --ttl and remove
#
# For usage with Thruk action menus use --menu to set actionmenu macro
# to a specific menu
#--------------------------------------------------------------------

import logging
import argparse
import os
import sys
import time
import json
import pprint
from jinja2 import Template

#-- Jinja2 template
SCRAPE_CONFIG = """[
  {
    "targets": [ "{{ ip }}" ],
    "labels": {
      "hostname": "{{ host }}",
      "snmpCommunity": "{{ community }}",
      {%- if labels %}
      {%- for key, value in labels %}
      "{{ key }}": "{{ value}}",
      {%- endfor %}
      {%- else %}

      {%- endif %}
      "mib": "{{ mib }}"
    }
  }
]
"""

#-- vars
ConfigPath = os.environ['OMD_ROOT'] + '/etc/snmp_exporter/targets/'
CmdFile = os.environ['OMD_ROOT'] + '/tmp/run/naemon.cmd'
CronTTL = 7

#-- Arguments
def arguments():
    parser = argparse.ArgumentParser(description='Create Prometheus SNMP-Exporter configuration',
		formatter_class=argparse.RawDescriptionHelpFormatter,
		epilog='%(prog)s -H XXX -i 127.0.0.1 -m if_mib -c <community> -l lable_key=label_value')
    parser.add_argument('--host','-H',dest='host',
                        help='OMD Hostname of target',
                        type=str, required=True)
    parser.add_argument('--ip','-i',dest='ip',
                        help='IP Address of target',
                        type=str, required=True)
    parser.add_argument('--community','-c',dest='community',
                        help='SNMP read community',
                        type=str, default='public')
    parser.add_argument('--mib','-m',dest='mib',
                        help='SNMP mib aka module',
                        type=str, default='if_mib')
    parser.add_argument('--config-path',dest='path',
                        help='Destination path for scrape config',
                        type=str, default=ConfigPath)
    parser.add_argument('--verbose','-v', dest='verbose',
                        help='Verbose output', action='store_true')
    parser.add_argument('--label','-l', action='append',
                        type=lambda kv: kv.split("="), dest='labels',
                        help='Append Prometheus labels -l key_a=value -l key_b=value')
    parser.add_argument('--ttl','-t', dest='ttl',
                        help='Time to life in days at crontab',
                        type=str, required=False)
    parser.add_argument('--menu',dest='menu',
                        help='Thruk action menu to set',
                        type=str, required=False)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--create',action="store_true",
                        help='Create scrape config')
    group.add_argument('--delete',action="store_true",
                        help='Delete scrape config')
    group.add_argument('--crontab',action="store_true",
                        help='Delete old configs as crontab job')
    return parser.parse_args()

#-- write scrape config
def output_config(tpl,**args):
  config = Template(tpl)
  logging.info("create scrape config")
  return config.render(args)
  
#-- change action menu
def set_menu(host,menu):
  logging.info("changing thruk action menu to {}".format(menu))
  if not os.path.exists(CmdFile):
    logging.error("no core cmd file found")
    sys.exit(2)
  try:
    f = open(CmdFile,'a')
  except IOError as e:
    logging.error("error during write to cmd file: {}".format(e))
    sys.exit(2)
  
  f.write("[{}] CHANGE_CUSTOM_HOST_VAR;{};THRUK_ACTION_MENU;{}\n".format(int(time.time()),host,menu))
  f.close()
  return 0

#
#-- MAIN
#
if __name__ == '__main__':
  args = vars(arguments())

  #-- Logging
  if args['verbose']:
    LEVEL = logging.DEBUG
  else:
    LEVEL = logging.INFO

  logging.basicConfig(level=LEVEL,
                      format='%(asctime)s %(levelname)s %(message)s',
                      )

  # check for config path
  if not os.path.exists(ConfigPath):
    logging.error("config path not found")
    sys.exit(2)
  else:
    logging.debug("config path set to : {}".format(ConfigPath))
    
  # build target filename
  TARGET = "snmp_scrape_" + args['host'] + ".json"

  # delete existing config 
  if args['delete']:
    logging.info("remove SNMP scrape config for {}".format(args['host']))
    try:
      os.remove(ConfigPath + TARGET)
    except OSError as e:
      logging.error("could not remove config for host {}: {}".format(args['host'],e))
      sys.exit(2)
    else:
      logging.info("config for host {} removed".format(args['host']))
      if args['menu']:
        set_menu(args['host'],args['menu'])
      sys.exit(0)

  # delete in crontab mode
  elif args['crontab']:
    if args['ttl']:
      CronTTL = int(args['ttl'])
    TTL = CronTTL * 3600 * 24
    logging.info("search for configs older than {} days".format(CronTTL))
    for file in os.listdir(ConfigPath):
      if file.endswith(".json") and int(os.path.getatime(ConfigPath + file)) < (int(time.time()) - TTL):
        try:
          cfg = json.load(open(ConfigPath + file,'r'))[0]
        except IOError as e:
          logging.error("could not read config {} : {}".format(file,e))
        else:
          if args['menu']:
            set_menu(cfg['labels']['hostname'],args['menu'])
          try:
            os.remove(ConfigPath + file)
          except OSError as e:
            logging.error("could not remove config for host {}: {}".format(args['host'],e))
          else:
            logging.info("scrape config for {} removed".format(cfg['labels']['hostname']))
    sys.exit(0)

  # new config
  elif args['create']:
    logging.info("new SNMP scrape config for {}".format(args['host']))
  
    # Check if host already exists
    if os.path.exists(ConfigPath + TARGET):
      logging.warning("scrape config for {} alrady in place".format(args['host']))
      if args['menu']:
        set_menu(args['host'],args['menu'])
      sys.exit(1)

    for dirpath, dirnames, files in os.walk(ConfigPath):
      for name in files:
        if name == TARGET:
          logging.warning("scrape config for {} alrady in place at {}".format(args['host'],os.path.join(dirpath, name)))
          sys.exit(1)

    # write scrape config
    if args['verbose']:
      logging.debug("{}".format(output_config(SCRAPE_CONFIG,**args)))

    try:
      f = open(ConfigPath + TARGET,'w') 
    except IOError as e:
      logging.error("error during write scrape config: {}".format(e))
      sys.exit(2)
    
    f.write(output_config(SCRAPE_CONFIG,**args))
    f.close()
    logging.info("scrape config written")
    
    # if menu is set, change action menu
    if args['menu']:
      set_menu(args['host'],args['menu'])
      logging.info("scrape config for {} successfully created".format(args['host']))

  # last exit
  else:
    logging.error("something went wrong ... sorry")
    sys.exit(2)    
