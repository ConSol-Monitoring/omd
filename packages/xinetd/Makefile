include ../../Makefile.omd

XINETD=2.3.15.3
# downloaded from https://packages.debian.org/source/stable/xinetd which maintains a source tarball working on aarch64
HAS_XINETD=$(shell grep -c "= xinetd" $(DISTRO_FILE) )
USE_TIRPC = $(shell grep -c 'tirpc' $(DISTRO_FILE) )

ifneq ($(USE_TIRPC), 0)
LDFLAGS+=$(shell pkg-config --libs libtirpc)
CFLAGS+=$(shell pkg-config --cflags libtirpc)
else
LDFLAGS?=
C_INCLUDE_PATH=
endif

# Fall back to GNU89 C standard and allow incompatible pointer types for
# compilers supporting this flag.
# From gcc >= 15 onwards (which has c23 as default)
# this old code will not compile without this flag anyway.
GCC_VERSION := $(shell $(CC) -dumpversion 2>/dev/null)
GCC_MAJOR := $(shell echo $(GCC_VERSION) | cut -d. -f1)
ifeq ($(shell test $(GCC_MAJOR) -ge 5 2>/dev/null && echo yes),yes)
CFLAGS+=-std=gnu89 -Wno-error=incompatible-pointer-types
endif

build:
ifeq ($(HAS_XINETD), 0)
	tar xvzf xinetd-$(XINETD).tar.gz
	cd xinetd-$(XINETD) && \
	    ./autogen.sh; \
	    ./configure --without-libwrap; \
	    $(MAKE) LDFLAGS="$(LDFLAGS)" CFLAGS="$(CFLAGS)"; \
	    strip ./xinetd
endif

install:
ifeq ($(HAS_XINETD), 0)
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	cp xinetd-$(XINETD)/xinetd $(DESTDIR)$(OMD_ROOT)/bin
endif

skel:

clean:
ifeq ($(HAS_XINETD), 0)
	rm -rf xinetd-$(XINETD)
endif
