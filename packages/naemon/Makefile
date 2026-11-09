include ../../Makefile.omd

NAME = naemon
CHANGELOG = https://github.com/naemon/naemon-core/blob/master/NEWS
VERSION = 1.5.1
DIR = $(NAME)-$(VERSION)
DEPENDS = jemalloc

# JEMALLOC_LIBS is consumed by the LDADD line in 9999-omd-link-jemalloc-into-naemon-binaries.patch.
# libnaemon.so.0 stays shared (used by both variants); only the naemon binaries get jemalloc.
JEMALLOC_LIB = $(firstword $(shell ls -d ../jemalloc/jemalloc-*/lib/libjemalloc.a 2>/dev/null))

# Configure options for Naemon. Since we want to compile
# as non-root, we use our own user and group for compiling.
# All files will be packaged as user 'root' later anyway.
CONFIGUREOPTS = \
    --bindir=$(OMD_ROOT)/bin \
    --libdir=$(OMD_ROOT)/lib \
    --with-naemon-user=$$(id -un) \
    --with-naemon-group=$$(id -gn) \
    --without-tests

CC = gcc
GCCVERSIONGTEQ7 := $(shell expr `gcc -dumpversion | cut -f1 -d.` \>= 7)

CFLAGS += -g3

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
	cd $(DIR) && CFLAGS="$(CFLAGS)" ./configure $(CONFIGUREOPTS)
	echo '#define OMD_VERSION "$(OMD_VERSION)"' >> $(DIR)/config.h
	$(MAKE) -C $(DIR) all

	# compilation with jemalloc: 9999-omd-link-jemalloc-into-naemon-binaries.patch modifies the Makefile.in of the version tarball
	# the patch only appends $(JEMALLOC_LIBS) to LDADD; upstream already links the naemon binary with -rdynamic

	# save the system-allocator naemon; the relink overwrites .libs/naemon
	cp $(DIR)/src/naemon/.libs/naemon $(DIR)/src/naemon/.libs/naemon-default

	@test -f "$(JEMALLOC_LIB)" || { echo "ERROR: jemalloc static library not found - build the 'jemalloc' package first"; exit 1; }
	ranlib $(JEMALLOC_LIB)

	# relink the naemon binary against static jemalloc -> naemon-jemalloc;
	# src/naemon/naemon is a libtool wrapper, a shell script that locates and runs the real binary in .libs/
	# it is a target of the make rule, removing it forces make to relink it with jemalloc in the next step
	rm -f $(DIR)/src/naemon/naemon

	# Force the heap API to resolve from libjemalloc.a.
	# To import objects from an archive, one normally starts and ends a --whole-archive import section:
	# -Wl,--whole-archive  archive1.a archive2.a  -Wl,--no-whole-archive
	# libtool moves "-Wl,--whole-archive" to the front (wrapping nothing) and leaves the archive at the end,
	# trailing and outside any whole-archive region.
	# This can effectively cause no objects from jemalloc being used, as the objects providing
	# malloc/free are alternatives to libc's.

	# On some toolchains/link orders (observed on Rocky 10) the bare trailing archive ends up unused:
	# the exe's only undefined heap symbol is free(), which libc also provides, so jemalloc.o is never pulled in.
	# Reproducible whenever libc is resolved before the archive.

	# -Wl,-u <function> marks malloc/calloc/realloc/free as required undefined symbols, so the linker pulls jemalloc.o from the archive.
	# Unlike --whole-archive this only pulls the objects that are actually needed, so jemalloc_cpp.o (which needs libstdc++) stays out.
	# The symbols are then defined+exported (-rdynamic) so libnaemon.so and dlopen'd NEB modules (e.g. livestatus.o) interpose on jemalloc.
	JEMALLOC_LIBS="-Wl,-u,malloc -Wl,-u,calloc -Wl,-u,realloc -Wl,-u,free $(abspath $(JEMALLOC_LIB)) -lpthread" $(MAKE) -C $(DIR) src/naemon/naemon
	mv $(DIR)/src/naemon/.libs/naemon $(DIR)/src/naemon/.libs/naemon-jemalloc
	strings $(DIR)/src/naemon/.libs/naemon-jemalloc | grep -q jemalloc || { echo "ERROR: naemon-jemalloc was linked without jemalloc"; exit 1; }
	cp $(DIR)/src/naemon/.libs/naemon-default $(DIR)/src/naemon/.libs/naemon.dbg
	cp $(DIR)/src/naemon/.libs/naemon-jemalloc $(DIR)/src/naemon/.libs/naemon-jemalloc.dbg
	cp $(DIR)/.libs/libnaemon.so.0.0.0 $(DIR)/.libs/libnaemon.so.0.0.0.dbg

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(DIR)/src/naemon/.libs/naemon.dbg          $(DESTDIR)$(OMD_ROOT)/bin/naemon.dbg
	install -m 755 $(DIR)/src/naemon/.libs/naemon-jemalloc.dbg $(DESTDIR)$(OMD_ROOT)/bin/naemon-jemalloc.dbg
	install -sm 755 $(DIR)/src/naemon/.libs/naemon-default     $(DESTDIR)$(OMD_ROOT)/bin/naemon
	install -sm 755 $(DIR)/src/naemon/.libs/naemon-jemalloc    $(DESTDIR)$(OMD_ROOT)/bin/naemon-jemalloc
	install -sm 755 $(DIR)/src/naemonstats/.libs/naemonstats   $(DESTDIR)$(OMD_ROOT)/bin
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib
	install -m 755 $(DIR)/.libs/libnaemon.so.0.0.0.dbg         $(DESTDIR)$(OMD_ROOT)/lib/libnaemon.so.0.0.0.dbg
	install -sm 755 $(DIR)/.libs/libnaemon.so.0.0.0            $(DESTDIR)$(OMD_ROOT)/lib
	ln -s libnaemon.so.0.0.0                                   $(DESTDIR)$(OMD_ROOT)/lib/libnaemon.so
	ln -s libnaemon.so.0.0.0                                   $(DESTDIR)$(OMD_ROOT)/lib/libnaemon.so.0
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/doc/naemon
	install -m 644 example.cfg                                $(DESTDIR)$(OMD_ROOT)/share/doc/naemon
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
