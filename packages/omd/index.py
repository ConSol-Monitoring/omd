#!/usr/bin/python

from mod_python import apache,util
import os, pwd

###
# FIXME: Copied from 'omd'. Should be placed in a library!
###

def site_name(req):
    return os.path.normpath(req.uri).split("/")[1]

def config_load(sitename):
    confpath = "/omd/sites/%s/etc/omd/site.conf" % sitename
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

def handler(req):
    sitename = site_name(req)
    config   = config_load(sitename)
    gui      = '/%s/nagios/' % sitename
    if 'WEB' in config:
        gui = '/%s/%s/' % (sitename, config['WEB'])
    util.redirect(req, gui)
    return apache.OK
