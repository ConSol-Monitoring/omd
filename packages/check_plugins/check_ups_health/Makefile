include ../../../Makefile.omd

NAME = check_ups_health
CHANGELOG   = https://github.com/lausser/check_ups_health/blob/master/ChangeLog
VERSION = 4.3.2
DIR = $(NAME)-$(VERSION)

.PHONY: skel

CONFIGUREOPTS = "--disable-standalone"

build:
	tar ozxf $(DIR).tar.gz
	cd $(DIR) ; ./configure $(CONFIGUREOPTS)
	$(MAKE) -C $(DIR)

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins
	install -m 755 $(DIR)/plugins-scripts/check_ups_health $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins

skel:

clean:
	rm -rf $(DIR)
