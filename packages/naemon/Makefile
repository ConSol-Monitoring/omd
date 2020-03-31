include ../../Makefile.omd

NAME = naemon
VERSION = 1.2.0
DIR = $(NAME)-$(VERSION)

# Configure options for Naemon. Since we want to compile
# as non-root, we use our own user and group for compiling.
# All files will be packaged as user 'root' later anyway.
CONFIGUREOPTS = \
    --bindir=$(OMD_ROOT)/bin \
    --with-naemon-user=$$(id -un) \
    --with-naemon-group=$$(id -gn) \
    --without-tests

CC = gcc
GCCVERSIONGTEQ7 := $(shell expr `gcc -dumpversion | cut -f1 -d.` \>= 7)
CFLAGS=

ifeq "$(GCCVERSIONGTEQ7)" "1"
  CFLAGS += -Wimplicit-fallthrough=0 \
            -Werror=format-truncation=0 \
            -Wno-cast-function-type
endif

build:
	tar xzf naemon-$(VERSION).tar.gz
	set -e ; for p in patches/*.patch ; do \
	    echo "applying $$p..." ; \
	    ( cd $(DIR) && patch -p1 -b -F 5 ) < $$p ; \
	done
	sed -i $(DIR)/configure -e 's/$(VERSION)\-source/$(VERSION)-omd/g'
	cd $(DIR) && CFLAGS="$(CFLAGS) -g3" ./configure $(CONFIGUREOPTS)
	$(MAKE) -C $(DIR) all

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	#install -m 755 $(DIR)/src/naemon/.libs/naemon             $(DESTDIR)$(OMD_ROOT)/bin/naemon.dbg
	install -sm 755 $(DIR)/src/naemon/.libs/naemon             $(DESTDIR)$(OMD_ROOT)/bin
	install -sm 755 $(DIR)/src/naemonstats/.libs/naemonstats   $(DESTDIR)$(OMD_ROOT)/bin
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib
	#install -m 755 $(DIR)/.libs/libnaemon.so.0.0.0            $(DESTDIR)$(OMD_ROOT)/lib/libnaemon.so.0.0.0.dbg
	install -sm 755 $(DIR)/.libs/libnaemon.so.0.0.0            $(DESTDIR)$(OMD_ROOT)/lib
	ln -s libnaemon.so.0.0.0                                   $(DESTDIR)$(OMD_ROOT)/lib/libnaemon.so
	ln -s libnaemon.so.0.0.0                                   $(DESTDIR)$(OMD_ROOT)/lib/libnaemon.so.0
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/doc/naemon
	install -m 644 example.cfg                                $(DESTDIR)$(OMD_ROOT)/share/doc/naemon
	install -m 755 purge_naemon                               $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 nq                                         $(DESTDIR)$(OMD_ROOT)/bin

skel:

clean:
	rm -rf $(DIR)

upstream: clean
	rm -f naemon-core-master.tar.gz
	wget https://github.com/naemon/naemon-core/tarball/master -O tmp.tar.gz
	tar zxf tmp.tar.gz
	mv naemon-naemon-core-??????? naemon-core-master
	cd naemon-core-master && autoreconf -i
	tar cfz naemon-core-master.tar.gz naemon-core-master
	git add naemon-core-master.tar.gz
	rm -rf naemon-core-master tmp.tar.gz
