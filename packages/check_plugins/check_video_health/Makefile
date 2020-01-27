include ../../../Makefile.omd

NAME = check_video_health
VERSION = 1.1.0.1
DIR = $(NAME)-$(VERSION)

.PHONY: skel

CONFIGUREOPTS = "--disable-standalone"

build:
	tar xzf $(DIR).tar.gz
	cd $(DIR) ; ./configure $(CONFIGUREOPTS)
	$(MAKE) -C $(DIR)

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins
	install -m 755 $(DIR)/plugins-scripts/check_video_health $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins

skel:

clean:
	rm -rf $(DIR)
