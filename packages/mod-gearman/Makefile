include ../../Makefile.omd

NAME         = mod_gearman
VERSION      = 5.0.3.20230307
DIR          = mod_gearman-$(VERSION)
PROXY        = GearmanProxy
PROXYVERSION = 2.08
PROXYDIR     = $(PROXY)-$(PROXYVERSION)
DEPENDS      = naemon gearmand

.PHONY: skel

build:
	tar xzf mod_gearman-$(VERSION).tar.gz
	#for p in patches/*.patch ; do \
	#    echo "applying $$p..." ; \
	#    ( cd $(DIR) ; patch -p1 ) < $$p || exit 1; \
	#done
	cd $(DIR) && \
	  export PKG_CONFIG_PATH=$(shell ls -d1 $$(pwd)/../naemon/naemon-*/.) C_INCLUDE_PATH=$(shell pwd)/$(DIR)/include:$(shell ls -d1 $$(pwd)/../naemon/naemon-*/.)/src; \
	  ./configure --prefix=$(OMD_ROOT) --libdir=$(OMD_ROOT)/lib --enable-debug --enable-embedded-perl --with-gearman=$(shell pwd)/../gearmand/dest && \
	  $(MAKE) -j 1
	tar zxf $(PROXYDIR).tar.gz
	cd $(PROXYDIR) && PERL5LIB=$$(pwd) perl Makefile.PL
	make -C $(PROXYDIR) gearman_proxy.pl

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 0755 calculate_required_worker           $(DESTDIR)$(OMD_ROOT)/bin/
	install -m 0755 $(DIR)/gearman_top                  $(DESTDIR)$(OMD_ROOT)/bin/
	install -m 0755 $(DIR)/send_gearman                 $(DESTDIR)$(OMD_ROOT)/bin/
	install -m 0755 $(DIR)/send_multi                   $(DESTDIR)$(OMD_ROOT)/bin/
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins
	install -m 0755 $(DIR)/check_gearman                $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins/
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/mod_gearman
	install -m 0644 $(DIR)/mod_gearman_naemon.o         $(DESTDIR)$(OMD_ROOT)/lib/mod_gearman/mod_gearman_naemon.o
	install -m 0644 $(DIR)/mod_gearman_naemon.o         $(DESTDIR)$(OMD_ROOT)/lib/mod_gearman/mod_gearman_naemon.o.dbg
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/mod_gearman
	install -m 0755 $(PROXYDIR)/gearman_proxy.pl        $(DESTDIR)$(OMD_ROOT)/share/mod_gearman/

skel:
	mkdir -p $(SKEL)/etc/mod-gearman
	mkdir -p $(SKEL)/tmp/run
	cp $(DIR)/etc/mod_gearman_neb.conf.in    $(SKEL)/etc/mod-gearman/server.cfg
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
