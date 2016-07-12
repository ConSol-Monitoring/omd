include ../../Makefile.omd

PLUGIN = check_sqlbase_health
PLUGIN_VERSION = 1.0
PLUGIN_DIR = $(PLUGIN)-$(PLUGIN_VERSION)

build:
	tar xf $(PLUGIN)-$(PLUGIN_VERSION).tar.gz
	cd $(PLUGIN_DIR) && \
	./configure && \
	$(MAKE)
	sed -e '1s|.*|#!/usr/bin/env perl|g' -i $(PLUGIN_DIR)/plugins-scripts/$(PLUGIN)
	sed -e 's|#!\ */usr/bin/perl|#!/usr/bin/env perl|g' -i $(PLUGIN_DIR)/plugins-scripts/$(PLUGIN)
	sed -e 's|#\ */usr/bin/perl|# /usr/bin/env perl|g' -i $(PLUGIN_DIR)/plugins-scripts/$(PLUGIN)

install:
	[ -d $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins ] || mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins
	install -m 755 $(PLUGIN_DIR)/plugins-scripts/$(PLUGIN) $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins

skel:

clean:
	rm -rf $(PLUGIN_DIR)
