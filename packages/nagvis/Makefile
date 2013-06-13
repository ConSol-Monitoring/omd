include ../../Makefile.omd

NAME = nagvis
VERSION = 1.7.9
DIR = $(NAME)-$(VERSION)

.PHONY: skel

build:
	tar xzf $(DIR).tar.gz
	patch $(DIR)/share/server/core/defines/global.php global.php.patch
	rm $(DIR)/share/server/core/defines/global.php.orig || true

install:
	cd $(DIR) ; ./install.sh -q -F -c y -a n \
	 -u $$(id -un) \
	 -g $$(id -gn) \
	 -w $(DESTDIR)$(OMD_ROOT)/etc/apache \
	 -W /WILL_BE_REPLACED/nagvis \
	 -b $(DESTDIR)/usr/bin \
	 -p $(DESTDIR)$(OMD_ROOT)/share/nagvis
	
	# Relocate the NagVis shared directory to have the same path as all the other packages
	test -d $(DESTDIR)$(OMD_ROOT)/share/nagvis/share && \
	  mv $(DESTDIR)$(OMD_ROOT)/share/nagvis/share $(DESTDIR)$(OMD_ROOT)/share/nagvis/htdocs
	
	mkdir -p $(DESTDIR)$(OMD_ROOT)/skel/var/nagvis/profiles
	
	# Move package documentations to have these files in the binary packages
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/doc/$(NAME)
	for file in LICENCE README ; do \
	  mv $(DESTDIR)$(OMD_ROOT)/share/nagvis/$$file $(DESTDIR)$(OMD_ROOT)/share/doc/$(NAME); \
	done
	
	# Take the sample main configuration file from source package and overwrite the one 
	# installed by the installer.
	mkdir -p $(DESTDIR)$(OMD_ROOT)/skel/etc/nagvis
	cp $(DIR)/etc/nagvis.ini.php-sample $(DESTDIR)$(OMD_ROOT)/skel/etc/nagvis/nagvis.ini.php
	
	# Move demo config files
	mkdir -p $(DESTDIR)$(OMD_ROOT)/skel/etc/nagvis/conf.d
	mkdir -p $(DESTDIR)$(OMD_ROOT)/skel/etc/nagvis/maps
	mkdir -p $(DESTDIR)$(OMD_ROOT)/skel/etc/nagvis/geomap
	mv $(DESTDIR)$(OMD_ROOT)/share/nagvis/etc/conf.d/*.ini.php $(DESTDIR)$(OMD_ROOT)/skel/etc/nagvis/conf.d
	mv $(DESTDIR)$(OMD_ROOT)/share/nagvis/etc/maps/*.cfg $(DESTDIR)$(OMD_ROOT)/skel/etc/nagvis/maps
	mv $(DESTDIR)$(OMD_ROOT)/share/nagvis/etc/geomap/demo-*.csv $(DESTDIR)$(OMD_ROOT)/skel/etc/nagvis/geomap
	
	# Delete files/directories we do not want to pack
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/nagvis/var
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/nagvis/etc
	
	# Update from NagVis 1.5 -> 1.6 in OMD handling needs to be handled here
	# The var/userfiles directory is not part of 1.6 anymore. But if the packe
	# would not contain var/nagvis/userfiles directories the "omd update" would remove
	# the directory tree, even if there are some custom files in it. This looks
	# like a bug in OMD. But to have a quick solution we simply create the empty
	# directory structure here for some versions. Can be removed someday...
	mkdir -p $(DESTDIR)$(OMD_ROOT)/skel/var/nagvis/userfiles/gadgets
	mkdir -p $(DESTDIR)$(OMD_ROOT)/skel/var/nagvis/userfiles/images/gadgets
	mkdir -p $(DESTDIR)$(OMD_ROOT)/skel/var/nagvis/userfiles/images/shapes
	mkdir -p $(DESTDIR)$(OMD_ROOT)/skel/var/nagvis/userfiles/images/iconsets
	mkdir -p $(DESTDIR)$(OMD_ROOT)/skel/var/nagvis/userfiles/images/maps
	mkdir -p $(DESTDIR)$(OMD_ROOT)/skel/var/nagvis/userfiles/images/templates
	mkdir -p $(DESTDIR)$(OMD_ROOT)/skel/var/nagvis/userfiles/styles
	mkdir -p $(DESTDIR)$(OMD_ROOT)/skel/var/nagvis/userfiles/sounds
	mkdir -p $(DESTDIR)$(OMD_ROOT)/skel/var/nagvis/userfiles/templates


clean:
	rm -rf $(NAME)-*.*.[0-9] $(NAME)-*.*-nightly
