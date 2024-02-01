include ../../Makefile.omd

NAME     = gearmand
VERSION  = 1.1.20
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
    --libdir=$(OMD_ROOT)/lib \
    --prefix=$(OMD_ROOT)

.PHONY: skel

TMPDEST=$(shell pwd)/dest

build: clean
	tar xzf gearmand-$(VERSION).tar.gz
	for p in patches/*.patch ; do \
	    echo "applying $$p..." ; \
	    ( cd $(DIR) ; patch -p1 ) < $$p || exit 1; \
	done
	cd $(DIR) && \
	CFLAGS="-g3" ./configure $(CONFIGUREOPTS)
	$(MAKE) -C $(DIR)
	$(MAKE) DESTDIR=$(TMPDEST) -C $(DIR) install
	rm -rf $(DIR)
	mv $(TMPDEST)$(OMD_ROOT)/* $(TMPDEST)/
	rm -rf $(TMPDEST)/omd

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)
	rsync -a $(TMPDEST)/. $(DESTDIR)$(OMD_ROOT)/.
	#cp $(DESTDIR)$(OMD_ROOT)/bin/gearmand $(DESTDIR)$(OMD_ROOT)/bin/gearmand.dbg

skel:

clean:
	rm -rf $(DIR)
	rm -rf $(TMPDEST)
