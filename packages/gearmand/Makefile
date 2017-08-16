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

CC = gcc
GCCVERSIONGTEQ7 := $(shell expr `gcc -dumpversion | cut -f1 -d.` \>= 7)
CFLAGS=-std=c99
CXXFLAGS=
ifeq "$(GCCVERSIONGTEQ7)" "1"
  CFLAGS += -fpermissive
  CXXFLAGS += -fpermissive
endif

.PHONY: skel

build: clean
	test -f gearmand-${VERSION}.tar.gz || wget "http://launchpad.net/gearmand/trunk/${VERSION}/+download/gearmand-${VERSION}.tar.gz"
	tar xzf gearmand-$(VERSION).tar.gz
	sed -i -e 's/boost_version_req=1.39/boost_version_req=1.34/g' gearmand-$(VERSION)/configure
	if [ $(BOOST) -ge 105300 ]; then \
		export LDFLAGS="-lboost_system"; \
		export LIBS="-lboost_system";  \
	fi && \
	cd $(DIR) && \
	export LIBRARY_PATH=$(shell ls -d1 ls -d1 /usr/lib*/boost*/. 2>/dev/null | tr '\n' ':') && \
	export LD_LIBRARY_PATH=$(shell ls -d1 ls -d1 /usr/lib*/boost*/. 2>/dev/null | tr '\n' ':') && \
	export CFLAGS="$(CFLAGS)" && \
	export CXXFLAGS="$(CXXFLAGS)" && \
	export CPATH=/usr/include/boost141 && \
	./configure $(CONFIGUREOPTS) && \
	$(MAKE)

install:
	$(MAKE) DESTDIR=$(DESTDIR) -C $(DIR) install

skel:
	mkdir -p $(SKEL)/var/log/gearman

clean:
	rm -rf $(DIR)
