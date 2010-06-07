include ../../Makefile.omd

NAME = nagvis
VERSION = 1.5-nightly
DIR = $(NAME)-$(VERSION)

.PHONY: skel

build:
	tar xzf $(DIR).tar.gz
	patch $(DIR)/share/server/core/defines/global.php global.php.patch

install:
	cd $(DIR) ; ./install.sh -q -F -c y -a n \
	 -u $$(id -un) \
	 -g $$(id -gn) \
	 -w $(DESTDIR)$(OMD_ROOT)/etc/apache \
	 -W /WILL_BE_REPLACED/nagvis \
	 -B $(DESTDIR)$(OMD_ROOT)/bin/nagios \
	 -b $(DESTDIR)/usr/bin \
	 -p $(DESTDIR)$(OMD_ROOT)/share/nagvis

	# Move directories
	mkdir -p $(DESTDIR)$(OMD_ROOT)/skel/var/nagvis
	mv $(DESTDIR)$(OMD_ROOT)/share/nagvis/share/userfiles $(DESTDIR)$(OMD_ROOT)/skel/var/nagvis/userfiles

	# Delete files we do not want to package
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/nagvis/var
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/nagvis/etc

skel:
	# Give Apache write permissions on certain directories
	chmod 770 $(SKEL)/etc/nagvis
	chmod 770 $(SKEL)/etc/nagvis/maps
	chmod 660 $(SKEL)/etc/nagvis/maps/*
	chmod 770 $(SKEL)/etc/nagvis/automaps
	chmod 660 $(SKEL)/etc/nagvis/automaps/*
	chmod 660 $(SKEL)/etc/nagvis/nagvis.ini.php
	chmod 660 $(SKEL)/etc/nagvis/auth.db
	chmod 770 $(SKEL)/var/nagvis/userfiles/images/maps
	chmod 660 $(SKEL)/var/nagvis/userfiles/images/maps/*
	chmod 770 $(SKEL)/var/nagvis/userfiles/images/shapes
	chmod 660 $(SKEL)/var/nagvis/userfiles/images/shapes/*
	chmod 770 $(SKEL)/tmp/nagvis
	chmod 770 $(SKEL)/tmp/nagvis/share
	chmod 770 $(SKEL)/tmp/nagvis/tmpl/compile
	chmod 770 $(SKEL)/tmp/nagvis/tmpl/cache

clean:
	rm -rf $(DIR)



