include ../../Makefile.omd

XINETD=2.3.15.3
# downloaded from https://packages.debian.org/source/stable/xinetd which maintains a source tarball working on aarch64
HAS_XINETD=$(shell grep -c "= xinetd" $(DISTRO_FILE) )
USE_TIRPC = $(shell grep -c 'tirpc' $(DISTRO_FILE) )

ifneq ($(USE_TIRPC), 0)
LDFLAGS+=$(shell pkg-config --libs libtirpc)
CFLAGS+= -O2 -std=gnu90 -Wno-strict-prototypes -Wno-error=incompatible-pointer-types $(shell pkg-config --cflags libtirpc)
else
LDFLAGS?=
CFLAGS+= -O2 -std=gnu90 -Wno-strict-prototypes -Wno-error=incompatible-pointer-types
endif

build:
ifeq ($(HAS_XINETD), 0)
	tar xvzf xinetd-$(XINETD).tar.gz
	for p in patches/*.patch ; do \
	    echo "applying $$p..." ; \
	    ( cd xinetd-$(XINETD) ; patch -p1 ) < $$p || exit 1; \
	done
	find xinetd-$(XINETD) -name \*.orig -exec rm {} \;
	cd xinetd-$(XINETD) && \
	    ./autogen.sh; \
	    ./configure --without-libwrap; \
	    make LDFLAGS="$(LDFLAGS)" CFLAGS="$(CFLAGS)"; \
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
