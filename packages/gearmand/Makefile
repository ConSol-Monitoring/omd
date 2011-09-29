include ../../Makefile.omd

NAME     = gearmand
VERSION  = 0.23
DIR      = gearmand-$(VERSION)

CONFIGUREOPTS = \
    --disable-libmemcached \
    --disable-libdrizzle \
    --disable-libpq \
    --disable-libsqlite3 \
    --disable-libtokyocabinet \
    --prefix=$(OMD_ROOT)

.PHONY: skel

build:
	test -f gearmand-${VERSION}.tar.gz || wget "http://launchpad.net/gearmand/trunk/${VERSION}/+download/gearmand-${VERSION}.tar.gz"
	tar xzf gearmand-$(VERSION).tar.gz
	sed -i -e 's/boost_version_req=1.39.0/boost_version_req=1.34.0/g' gearmand-$(VERSION)/configure
	cd $(DIR) && \
	export LIBRARY_PATH=/usr/lib64/boost141:/usr/lib/boost141 && \
	export LD_LIBRARY_PATH=/usr/lib64/boost141:/usr/lib/boost141 && \
	export CPATH=/usr/include/boost141 && \
	./configure $(CONFIGUREOPTS) && \
	$(MAKE) 

install:
	$(MAKE) DESTDIR=$(DESTDIR) -C $(DIR) install

skel:

clean:
	rm -rf $(DIR)
