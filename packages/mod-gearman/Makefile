include ../../Makefile.omd

NAME     = mod_gearman
VERSION  = 1.1.0
GEARMAND = $(shell grep "^VERSION " ../gearmand/Makefile | awk '{ print $$3 }')
DIR      = mod_gearman-$(VERSION)

.PHONY: skel

build:
	test -f mod_gearman-${VERSION}.tar.gz || wget "http://labs.consol.de/wp-content/uploads/2010/09/mod_gearman-$(VERSION).tar.gz"
	tar xzf mod_gearman-$(VERSION).tar.gz
	#for p in patches/*.patch ; do \
	#    echo "applying $$p..." ; \
	#    ( cd $(DIR) ; patch -p1 -b ) < $$p ; \
	#done
	cd $(DIR) && \
    export LIBRARY_PATH=$(shell pwd)/../gearmand/gearmand-${GEARMAND}/libgearman/.libs && \
    export LD_LIBRARY_PATH=$(shell pwd)/../gearmand/gearmand-${GEARMAND}/libgearman/.libs && \
    ./configure --prefix=$(OMD_ROOT) && \
    $(MAKE) -j 1

install:
	$(MAKE) DESTDIR=$(DESTDIR) -C $(DIR) -j 1 install
	# fix path for plugin
	[ -d $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins ] || mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins
	mv $(DESTDIR)$(OMD_ROOT)/bin/check_gearman $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins/
	rm -rf $(DESTDIR)$(OMD_ROOT)/etc/mod-gearman
	rm -rf $(DESTDIR)$(OMD_ROOT)/etc/init.d/gearmand
	rm -rf $(DESTDIR)$(OMD_ROOT)/etc/init.d/mod_gearman_worker
	rmdir $(DESTDIR)$(OMD_ROOT)/etc/init.d
	rmdir $(DESTDIR)$(OMD_ROOT)/etc
	rm -rf $(DESTDIR)$(OMD_ROOT)/var/mod_gearman
	rmdir $(DESTDIR)$(OMD_ROOT)/var

skel:

clean:
	rm -rf $(DIR)
