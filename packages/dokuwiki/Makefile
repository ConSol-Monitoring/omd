include ../../Makefile.omd

NAME = dokuwiki
VERSION = 2009-12-25c
DIR = $(NAME)-2009-12-25

.PHONY: skel

build:
	tar xzf  $(NAME)-$(VERSION).tgz
	tar xzf  template-arctic.tgz -C $(DIR)/lib/tpl/

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/dokuwiki
	cp preload.php $(DIR)/inc/
	touch $(DIR)/lib/plugins/plugin/disabled
	touch $(DIR)/conf $(DIR)/data
	rm -r $(DIR)/conf $(DIR)/data
	cp -r $(DIR) $(DESTDIR)$(OMD_ROOT)/share/dokuwiki/htdocs

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
	chmod 770 $(SKEL)/var/dokuwiki/data/tmp
	chmod 660 $(SKEL)/etc/dokuwiki/local.php
	chmod 660 $(SKEL)/etc/dokuwiki/acl.auth.php
	chmod 660 $(SKEL)/etc/dokuwiki/users.auth.php

clean:
	# Remove files created by build/install
