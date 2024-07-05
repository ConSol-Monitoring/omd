include ../../Makefile.omd

NAME = freetds
FREETDS_VERSION = 1.4.19
FREETDS_DIR = freetds-$(FREETDS_VERSION)
SHELL = /bin/bash

build:
	# ftp://ftp.freetds.org/pub/freetds/stable/freetds-stable.tgz
	tar xf freetds-$(FREETDS_VERSION).tar.gz
	#cd $(FREETDS_DIR) && patch -p1 < ../0001-ct_connect-allow-host.patch
	cd $(FREETDS_DIR) && \
	./configure --prefix=$(OMD_ROOT) --libdir=$(OMD_ROOT)/lib --with-openssl && \
	$(MAKE) && $(MAKE) DESTDIR=$(shell pwd)/tmpinstall install
	$(MAKE) DESTDIR=$(DESTDIR) -C $(FREETDS_DIR)

install:
	$(MAKE) DESTDIR=$(DESTDIR) -C $(FREETDS_DIR) install
	rm -rf $(DESTDIR)$(OMD_ROOT)/etc/freetds.conf
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/doc/$(FREETDS_DIR)
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/doc/freetds
	rm -rf tmpinstall

skel:

clean:
	rm -rf $(FREETDS_DIR)
	rm -rf tmpinstall

upstream:
	rm -rf freetds-$(FREETDS_VERSION).tar.gz
	wget ftp://ftp.freetds.org/pub/freetds/stable/freetds-$(FREETDS_VERSION).tar.gz
