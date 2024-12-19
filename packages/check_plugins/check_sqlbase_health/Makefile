include ../../../Makefile.omd

PLUGIN = check_sqlbase_health
CHANGELOG   = https://github.com/lausser/check_sqlbase_health/blob/master/ChangeLog
VERSION = 2.0
DIR = $(PLUGIN)-$(VERSION)

build:
	tar xf $(DIR).tar.gz
	cd $(DIR) && \
	./configure && \
	$(MAKE)
	sed -e '1s|.*|#!/usr/bin/env perl|g' -i $(DIR)/plugins-scripts/$(PLUGIN)
	sed -e 's|#!\ */usr/bin/perl|#!/usr/bin/env perl|g' -i $(DIR)/plugins-scripts/$(PLUGIN)
	sed -e 's|#\ */usr/bin/perl|# /usr/bin/env perl|g' -i $(DIR)/plugins-scripts/$(PLUGIN)

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins
	install -m 755 $(DIR)/plugins-scripts/$(PLUGIN) $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins

skel:

clean:
	rm -rf $(DIR)
