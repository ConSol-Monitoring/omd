include ../../../Makefile.omd

NAME = check_sap_health
CHANGELOG   = https://github.com/lausser/check_sap_health/blob/master/ChangeLog
VERSION = 4.0.0.3
DIR = $(NAME)-$(VERSION)

.PHONY: skel

#CONFIGUREOPTS = "--disable-standalone"

build:
	tar ozxf $(DIR).tar.gz
	cd $(DIR) ; ./configure $(CONFIGUREOPTS)
	$(MAKE) -C $(DIR)

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins
	install -m 755 $(DIR)/plugins-scripts/check_sap_health $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins

skel:

clean:
	rm -rf $(DIR)
