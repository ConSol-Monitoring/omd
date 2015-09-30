include ../../Makefile.omd

NAME     = mod_gearman
VERSION  = 1.5.5
GEARMAND = $(shell grep "^VERSION " ../gearmand/Makefile | awk '{ print $$3 }')
DIR      = mod_gearman-$(VERSION)

.PHONY: skel

build:
	test -f mod_gearman-${VERSION}.tar.gz || wget "http://labs.consol.de/wp-content/uploads/2010/09/mod_gearman-$(VERSION).tar.gz"
	tar xzf mod_gearman-$(VERSION).tar.gz
	#for p in patches/*.patch ; do \
	#    echo "applying $$p..." ; \
	#    ( cd $(DIR) ; patch -p1 -b ) < $$p || exit 1; \
	#done
	cd $(DIR) && \
	./configure --prefix=$(OMD_ROOT) --enable-embedded-perl --with-gearman=$(shell pwd)/../gearmand/gearmand-${GEARMAND} && \
	$(MAKE) -j 1

install:
	$(MAKE) DESTDIR=$(DESTDIR) -C $(DIR) -j 1 install
	# fix path for plugin
	[ -d $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins ] || mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins
	mv $(DESTDIR)$(OMD_ROOT)/bin/check_gearman $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins/
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/mod_gearman/*.conf
	rm -f $(DESTDIR)$(OMD_ROOT)/lib/mod_gearman/mod_gearman.so
	rm -rf $(DESTDIR)$(OMD_ROOT)/etc
	rm -rf $(DESTDIR)$(OMD_ROOT)/var

skel:
	mkdir -p $(SKEL)/etc/mod-gearman
	cp $(DIR)/etc/mod_gearman_neb.conf.in    $(SKEL)/etc/mod-gearman/server.cfg
	cp $(DIR)/etc/mod_gearman_worker.conf.in $(SKEL)/etc/mod-gearman/worker.cfg
	for p in patches/*.skel_patch ; do \
	    echo "applying $$p..." ; \
	    ( cd $(SKEL) ; patch -p1 ) < $$p || exit 1; \
	done
	find $(SKEL)/etc/mod-gearman -name \*.orig -exec rm {} \;
	mkdir -p $(SKEL)/var/log/mod_gearman
	touch $(SKEL)/var/log/mod_gearman/neb.log
	touch $(SKEL)/var/log/mod_gearman/worker.log



clean:
	rm -rf $(DIR)
