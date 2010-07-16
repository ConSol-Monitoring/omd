# Extract site from our own absolute filename :-)
# __file__ should be /omd/sites/###SITE###/share/check_mk/web/htdocs/defaults.py

site = __file__.split("/")[3]
execfile('/omd/sites/%s/etc/check_mk/defaults' % site)
