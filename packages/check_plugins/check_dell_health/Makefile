include ../../../Makefile.omd

NAME = check_dell_health
VERSION = 1.0.0.6
DIR = $(NAME)-$(VERSION)

.PHONY: skel

CONFIGUREOPTS = "--disable-standalone"

build:
	tar xzf $(DIR).tar.gz
	cd $(DIR) ; ./configure $(CONFIGUREOPTS)
	$(MAKE) -C $(DIR)

install:
	[ -d $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins ] || mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins
	install -m 755 $(DIR)/plugins-scripts/check_dell_health $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins

skel:

clean:
	rm -rf $(DIR)
