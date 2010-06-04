include ../../Makefile.omd

NAME = nagvis
VERSION = 1.5rc3
DIR = $(NAME)-$(VERSION)

.PHONY: skel

build:
	tar xzf $(DIR).tar.gz

install:
	cd $(DIR) ; ./install.sh -q -F -c y \
	 -u $$(id -un) \
	 -g $$(id -gn) \
	 -w $(DESTDIR)$(OMD_ROOT)/etc/apache \
	 -W /lars/nagvis \
	 -B $(DESTDIR)$(OMD_ROOT)/bin/nagios \
   -b $(DESTDIR)/usr/bin \
	 -p $(DESTDIR)$(OMD_ROOT)/share/nagvis

	# Move directories
	#mv $(DESTDIR)$(OMD_ROOT)/share/nagvis/var $(DESTDIR)$(OMD_ROOT)

	# Delete files we do not want to package
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/nagvis/var

skel:
	# Give Apache write permissions on certain directories
	#chmod 770 $(SKEL)/var/check_mk/web
	#chmod 770 $(SKEL)/var/check_mk/logwatch

clean:
	rm -rf $(DIR)



