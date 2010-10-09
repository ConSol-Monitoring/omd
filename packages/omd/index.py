#!/usr/bin/python

from mod_python import apache,util
import os, pwd

###
# FIXME: Copied from 'omd'. Should be placed in a library!
###

def site_name():
    return pwd.getpwuid(os.getuid()).pw_name

def config_load():
    confpath = "/omd/sites/%s/etc/omd/site.conf" % g_sitename
    if not os.path.exists(confpath):
        return {}

    conf = {}
    for line in file(confpath):
	line = line.strip()
	if line == "" or line[0] == "#":
	    continue
	var, value = line.split("=", 1)
        conf[var.strip()[7:]] = value.strip('"').strip("'")
    return conf

g_sitename = site_name()
g_config = config_load()

def handler(req):
    gui = '/%s/nagios/' % g_sitename
    if 'WEB' in g_config:
        gui = '/%s/%s/' % (g_sitename, g_config['WEB'])
    util.redirect(req, gui)
    return apache.OK
