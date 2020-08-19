include ../../Makefile.omd

NAME     = gearmand
VERSION  = 1.1.19.1
DIR      = gearmand-$(VERSION)
SHELL    = /bin/bash

CONFIGUREOPTS = \
    --disable-libmemcached \
    --disable-hiredis \
    --disable-libdrizzle \
    --disable-libpq \
    --disable-libtokyocabinet \
    --without-mysql \
    --sbindir=$(OMD_ROOT)/bin \
    --prefix=$(OMD_ROOT)

.PHONY: skel

build: clean
	tar xzf gearmand-$(VERSION).tar.gz
	for p in patches/*.patch ; do \
	    echo "applying $$p..." ; \
	    ( cd $(DIR) ; patch -p1 ) < $$p || exit 1; \
	done
	cd $(DIR) && \
	CFLAGS="-g3" ./configure $(CONFIGUREOPTS)
	$(MAKE) -C $(DIR)

install:
	$(MAKE) DESTDIR=$(DESTDIR) -C $(DIR) install
	#cp $(DESTDIR)/$(OMD_ROOT)/bin/gearmand $(DESTDIR)/$(OMD_ROOT)/bin/gearmand.dbg

skel:

clean:
	rm -rf $(DIR)
