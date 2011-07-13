include ../../Makefile.omd

NAME = nagvis
#VERSION = 1.5.9
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
	
	# And last but not least relocate the NagVis shared directory to have the same path
	# as all the other packages
	test -d $(DESTDIR)$(OMD_ROOT)/share/nagvis/share && \
	  mv $(DESTDIR)$(OMD_ROOT)/share/nagvis/share $(DESTDIR)$(OMD_ROOT)/share/nagvis/htdocs
	
	# Move userfiles to skel to allow site specific modifications
	mkdir -p $(DESTDIR)$(OMD_ROOT)/skel/var/nagvis
	mv $(DESTDIR)$(OMD_ROOT)/share/nagvis/htdocs/userfiles $(DESTDIR)$(OMD_ROOT)/skel/var/nagvis/userfiles
	
	# Move package documentations to have these files in the binary packages
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/doc/$(NAME)
	for file in LICENCE README ; do \
	  mv $(DESTDIR)$(OMD_ROOT)/share/nagvis/$$file $(DESTDIR)$(OMD_ROOT)/share/doc/$(NAME); \
	done
	
	# Delete files/directories we do not want to pack
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/nagvis/var
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/nagvis/etc


clean:
	rm -rf $(NAME)-*.*.[0-9] $(NAME)-*.*-nightly
