include ../../../Makefile.omd

NAME = check_mailbox_health
CHANGELOG   = https://github.com/lausser/check_mailbox_health/blob/master/ChangeLog
VERSION = 2.0.0.1
DIR = $(NAME)-$(VERSION)

.PHONY: skel

CONFIGUREOPTS = "--disable-standalone"

build:
	tar ozxf $(DIR).tar.gz
	cd $(DIR) ; ./configure $(CONFIGUREOPTS)
	$(MAKE) -C $(DIR)

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins
	install -m 755 $(DIR)/plugins-scripts/check_mailbox_health $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins

skel:

clean:
	rm -rf $(DIR)
