include ../../Makefile.omd

NAME = dokuwiki
VERSION = 2009-12-25c
DIR = $(NAME)-2009-12-25

.PHONY: skel

build:
	tar xzf $(NAME)-$(VERSION).tgz
	tar xzf template-arctic.tgz -C $(DIR)/lib/tpl/
	tar xzf plugin-include.tgz -C $(DIR)/lib/plugins/

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/dokuwiki
	cp preload.php $(DIR)/inc/
	touch $(DIR)/lib/plugins/plugin/disabled
	touch $(DIR)/conf $(DIR)/data
	rm -r $(DIR)/conf $(DIR)/data
	cp -r $(DIR) $(DESTDIR)$(OMD_ROOT)/share/dokuwiki/htdocs
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/doc/dokuwiki
	install -m 644 $(DIR)/README $(DESTDIR)$(OMD_ROOT)/share/doc/dokuwiki
	install -m 644 $(DIR)/COPYING $(DESTDIR)$(OMD_ROOT)/share/doc/dokuwiki
	install -m 644 $(DIR)/VERSION $(DESTDIR)$(OMD_ROOT)/share/doc/dokuwiki


skel:
	# Optional target called to create additional files below skel
	chmod 770 $(SKEL)/var/dokuwiki/data
	chmod 770 $(SKEL)/var/dokuwiki/data/attic
	chmod 770 $(SKEL)/var/dokuwiki/data/cache
	chmod 770 $(SKEL)/var/dokuwiki/data/index
	chmod 770 $(SKEL)/var/dokuwiki/data/locks
	chmod 770 $(SKEL)/var/dokuwiki/data/media
	chmod 770 $(SKEL)/var/dokuwiki/data/meta
	chmod 770 $(SKEL)/var/dokuwiki/data/pages
	chmod 775 $(SKEL)/var/dokuwiki/data/tmp
	chmod 770 $(SKEL)/etc/dokuwiki
	chmod 660 $(SKEL)/etc/dokuwiki/local.php
	chmod 660 $(SKEL)/etc/dokuwiki/acl.auth.php
	chmod 660 $(SKEL)/etc/dokuwiki/users.auth.php

clean:
	# Remove files created by build/install
	rm -r $(DIR)
