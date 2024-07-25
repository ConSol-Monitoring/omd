include ../../../Makefile.omd

NAME = check_hpasm
VERSION = 4.10
DIR = $(NAME)-$(VERSION)

.PHONY: skel

CONFIGUREOPTS = ""

build:
	tar ozxf $(DIR).tar.gz
	cd $(DIR) ; ./configure $(CONFIGUREOPTS)
	$(MAKE) -C $(DIR)

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins
	install -m 755 $(DIR)/plugins-scripts/check_hpasm $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins

skel:

clean:
	rm -rf $(DIR)
