include ../../Makefile.omd

NAME         = mod_gearman
VERSION      = 3.3.0
GEARMAND     = $(shell grep "^VERSION " ../gearmand/Makefile | awk '{ print $$3 }')
DIR          = mod_gearman-$(VERSION)
PROXY        = GearmanProxy
PROXYVERSION = 2.07
PROXYDIR     = $(PROXY)-$(PROXYVERSION)

.PHONY: skel

build:
	tar xzf mod_gearman-$(VERSION).tar.gz
	#for p in patches/*.patch ; do \
	#    echo "applying $$p..." ; \
	#    ( cd $(DIR) ; patch -p1 ) < $$p || exit 1; \
	#done
	cd $(DIR) && \
	  export PKG_CONFIG_PATH=$(shell ls -d1 $$(pwd)/../naemon/naemon-*/.) C_INCLUDE_PATH=$(shell pwd)/$(DIR)/include:$(shell ls -d1 $$(pwd)/../naemon/naemon-*/.)/src; \
	  ./configure --prefix=$(OMD_ROOT) --enable-debug --enable-embedded-perl --with-gearman=$(shell pwd)/../gearmand/gearmand-${GEARMAND} && \
	  $(MAKE) -j 1
	tar zxf $(PROXYDIR).tar.gz
	cd $(PROXYDIR) && perl Makefile.PL
	make -C $(PROXYDIR) gearman_proxy.pl

install:
	$(MAKE) DESTDIR=$(DESTDIR) -C $(DIR) -j 1 install
	# fix path for plugin
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins
	mv $(DESTDIR)$(OMD_ROOT)/bin/check_gearman $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins/
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/mod_gearman/*.conf
	rm -f $(DESTDIR)$(OMD_ROOT)/lib/mod_gearman/mod_gearman.so
	#cp $(DESTDIR)$(OMD_ROOT)/lib/mod_gearman/mod_gearman_naemon.o $(DESTDIR)$(OMD_ROOT)/lib/mod_gearman/mod_gearman_naemon.o.dbg
	rm -rf $(DESTDIR)$(OMD_ROOT)/lib/mod_gearman/mod_gearman_nagios*
	#cp $(DESTDIR)$(OMD_ROOT)/bin/mod_gearman_worker $(DESTDIR)$(OMD_ROOT)/bin/mod_gearman_worker.dbg
	rm -rf $(DESTDIR)$(OMD_ROOT)/etc
	rm -rf $(DESTDIR)$(OMD_ROOT)/var
	install -m 0755 $(PROXYDIR)/gearman_proxy.pl $(DESTDIR)$(OMD_ROOT)/share/mod_gearman/gearman_proxy.pl

skel:
	mkdir -p $(SKEL)/etc/mod-gearman
	mkdir -p $(SKEL)/tmp/run
	cp $(DIR)/etc/mod_gearman_neb.conf.in    $(SKEL)/etc/mod-gearman/server.cfg
	cp $(DIR)/etc/mod_gearman_worker.conf.in $(SKEL)/etc/mod-gearman/worker.cfg
	cp $(PROXYDIR)/gearman_proxy.cfg         $(SKEL)/etc/mod-gearman/gearman_proxy.cfg
	for p in patches/*.skel_patch ; do \
	    echo "applying $$p..." ; \
	    ( cd $(SKEL) ; patch -p1 ) < $$p || exit 1; \
	done
	find $(SKEL)/etc/mod-gearman -name \*.orig -exec rm {} \;
	mkdir -p $(SKEL)/var/log/
	cd $(SKEL)/var/log/ && ln -s gearman mod_gearman



clean:
	rm -rf $(DIR)
	rm -rf $(PROXYDIR)
