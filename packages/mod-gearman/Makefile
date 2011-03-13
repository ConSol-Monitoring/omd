include ../../Makefile.omd

NAME     = mod_gearman
VERSION  = 1.0.2
DIR      = mod_gearman-$(VERSION)

.PHONY: skel

build:
	test -f mod_gearman-${VERSION}.tar.gz || wget "http://labs.consol.de/wp-content/uploads/2010/09/mod_gearman-$(VERSION).tar.gz"
	tar xzf mod_gearman-$(VERSION).tar.gz
	cd $(DIR) && \
    export LIBRARY_PATH=$(shell pwd)/../gearmand/gearmand-0.14/libgearman/.libs && \
    export LD_LIBRARY_PATH=$(shell pwd)/../gearmand/gearmand-0.14/libgearman/.libs && \
    ./configure --prefix=$(OMD_ROOT) && \
	$(MAKE) -j 1

install:
	$(MAKE) DESTDIR=$(DESTDIR) -C $(DIR) -j 1 install
	# fix path for plugin
	[ -d $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins ] || mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins
	mv $(DESTDIR)$(OMD_ROOT)/bin/check_gearman $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins/
	rm -rf $(DESTDIR)$(OMD_ROOT)/etc/mod-gearman

skel:

clean:
	rm -rf $(DIR)
