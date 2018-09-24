include ../../../Makefile.omd

NAME = check_hpasm
VERSION = 4.8
DIR = $(NAME)-$(VERSION)

.PHONY: skel

CONFIGUREOPTS = ""

build:
	tar xzf $(DIR).tar.gz
	cd $(DIR) ; ./configure $(CONFIGUREOPTS)
	$(MAKE) -C $(DIR)

install:
	[ -d $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins ] || mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins
	install -m 755 $(DIR)/plugins-scripts/check_hpasm $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins

skel:

clean:
	rm -rf $(DIR)
