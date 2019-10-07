include ../../Makefile.omd

NAME     = gearmand
VERSION  = 1.1.18
DIR      = gearmand-$(VERSION)
SHELL    = /bin/bash
BOOST    = $(shell grep '^\#define\s*BOOST_VERSION\s*[0-9][0-9]*' /usr/include/boost/version.hpp /usr/include/boost*/boost/version.hpp 2>/dev/null | awk '{ print $$3 }' )

CONFIGUREOPTS = \
    --disable-libmemcached \
    --disable-hiredis \
    --disable-libdrizzle \
    --disable-libpq \
    --disable-libtokyocabinet \
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
	cp $(DESTDIR)/$(OMD_ROOT)/bin/gearmand $(DESTDIR)/$(OMD_ROOT)/bin/gearmand.dbg

skel:

clean:
	rm -rf $(DIR)
