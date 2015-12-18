include ../../Makefile.omd

NAME = check_mssql_health
CHECK_MSSQL_HEALTH_VERSION = 1.6.2.3
CHECK_MSSQL_HEALTH_DIR = check_mssql_health-$(CHECK_MSSQL_HEALTH_VERSION)
SHELL = /bin/bash

build:
	tar xf check_mssql_health-$(CHECK_MSSQL_HEALTH_VERSION).tar.gz
	cd $(CHECK_MSSQL_HEALTH_DIR) && \
	./configure && \
	$(MAKE)

install:
	[ -d $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins ] || mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins
	install -m 755 $(CHECK_MSSQL_HEALTH_DIR)/plugins-scripts/check_mssql_health $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins

skel:

clean:
	rm -rf $(CHECK_MSSQL_HEALTH_DIR)
