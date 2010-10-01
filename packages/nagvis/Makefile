include ../../Makefile.omd

NAME = nagvis
VERSION = 1.5.2
DIR = $(NAME)-$(VERSION)

.PHONY: skel

build:
	tar xzf $(DIR).tar.gz
	patch $(DIR)/share/server/core/defines/global.php global.php.patch
	patch $(DIR)/share/server/core/classes/GlobalMainCfg.php disable-maincfg-cache.patch

install:
	cd $(DIR) ; ./install.sh -q -F -c y -a n \
	 -u $$(id -un) \
	 -g $$(id -gn) \
	 -w $(DESTDIR)$(OMD_ROOT)/etc/apache \
	 -W /WILL_BE_REPLACED/nagvis \
	 -B $(DESTDIR)$(OMD_ROOT)/bin/nagios \
	 -b $(DESTDIR)/usr/bin \
	 -p $(DESTDIR)$(OMD_ROOT)/share/nagvis

	# Move userfiles to skel to allow site specific modifications
	mkdir -p $(DESTDIR)$(OMD_ROOT)/skel/var/nagvis
	mv $(DESTDIR)$(OMD_ROOT)/share/nagvis/share/userfiles $(DESTDIR)$(OMD_ROOT)/skel/var/nagvis/userfiles

	# Move package documentations to have these files in the binary packages
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/doc/$(NAME)
	for file in LICENCE README ; do \
	   mv $(DESTDIR)$(OMD_ROOT)/share/nagvis/$$file $(DESTDIR)$(OMD_ROOT)/share/doc/$(NAME); \
   	done

	# Delete files/directories we do not want to pack
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/nagvis/var
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/nagvis/etc

skel:
	# Give Apache write permissions on certain directories
	chmod 775 $(SKEL)/etc/nagvis
	chmod 775 $(SKEL)/etc/nagvis/maps
	chmod 664 $(SKEL)/etc/nagvis/maps/*
	chmod 775 $(SKEL)/etc/nagvis/automaps
	chmod 664 $(SKEL)/etc/nagvis/automaps/*
	chmod 664 $(SKEL)/etc/nagvis/nagvis.ini.php
	chmod 664 $(SKEL)/etc/nagvis/nagvis-omd.ini.php
	chmod 664 $(SKEL)/etc/nagvis/auth.db
	chmod 775 $(SKEL)/var/nagvis/userfiles/images/maps
	chmod 664 $(SKEL)/var/nagvis/userfiles/images/maps/*
	chmod 775 $(SKEL)/var/nagvis/userfiles/images/shapes
	chmod 664 $(SKEL)/var/nagvis/userfiles/images/shapes/*
	chmod 775 $(SKEL)/tmp/nagvis
	chmod 775 $(SKEL)/tmp/nagvis/share
	chmod 775 $(SKEL)/tmp/nagvis/tmpl/compile
	chmod 775 $(SKEL)/tmp/nagvis/tmpl/cache

clean:
	rm -rf $(DIR)



