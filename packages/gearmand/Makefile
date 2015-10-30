include ../../Makefile.omd

NAME     = gearmand
VERSION  = 0.33
DIR      = gearmand-$(VERSION)
SHELL    = /bin/bash
BOOST    = $(shell grep '^\#define\s*BOOST_VERSION\s*[0-9][0-9]*' /usr/include/boost/version.hpp /usr/include/boost*/boost/version.hpp 2>/dev/null | awk '{ print $$3 }' )

CONFIGUREOPTS = \
    --disable-libmemcached \
    --disable-libdrizzle \
    --disable-libpq \
    --disable-libtokyocabinet \
    --with-sqlite3=no \
    --prefix=$(OMD_ROOT)

.PHONY: skel

build: clean
	test -f gearmand-${VERSION}.tar.gz || wget "http://launchpad.net/gearmand/trunk/${VERSION}/+download/gearmand-${VERSION}.tar.gz"
	tar xzf gearmand-$(VERSION).tar.gz
	sed -i -e 's/boost_version_req=1.39/boost_version_req=1.34/g' gearmand-$(VERSION)/configure
	DISTRO_VERSION=$(DISTRO_VERSION); \
	if [ "$(DISTRO_NAME)" = "CENTOS" -a "$${DISTRO_VERSION:0:1}" = "5" ]; then \
		export CC='gcc44'; \
		export CXX='g++44'; \
	fi && \
	if [ $(BOOST) -ge 105300 ]; then \
		export LDFLAGS="-lboost_system"; \
		export LIBS="-lboost_system";  \
	fi && \
	cd $(DIR) && \
	export LIBRARY_PATH=$(shell ls -d1 ls -d1 /usr/lib*/boost*/. 2>/dev/null | tr '\n' ':') && \
	export LD_LIBRARY_PATH=$(shell ls -d1 ls -d1 /usr/lib*/boost*/. 2>/dev/null | tr '\n' ':') && \
	export CFLAGS=-std=c99 && \
	export CPATH=/usr/include/boost141 && \
	./configure $(CONFIGUREOPTS) && \
	$(MAKE)

install:
	$(MAKE) DESTDIR=$(DESTDIR) -C $(DIR) install

skel:
	mkdir -p $(SKEL)/var/log/gearman
	touch $(SKEL)/var/log/gearman/gearman.log

clean:
	rm -rf $(DIR)
