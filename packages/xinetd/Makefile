include ../../Makefile.omd

XINETD=2-3-15
HAS_XINETD=$(shell grep -c "= xinetd" $(DISTRO_FILE) )
USE_TIRPC = $(shell grep -c 'tirpc' $(DISTRO_FILE) )

ifneq ($(USE_TIRPC), 0)
LDFLAGS=$(shell pkg-config --libs libtirpc)
CFLAGS=$(shell pkg-config --cflags libtirpc)
else
LDFLAGS=
C_INCLUDE_PATH=
endif

build:
ifeq ($(HAS_XINETD), 0)
	tar xvzf xinetd-$(XINETD).tar.gz
	cd xinetd-xinetd-$(XINETD) && \
	    ./configure; \
	    make LDFLAGS=$(LDFLAGS) CFLAGS=$(CFLAGS); \
	    strip xinetd/xinetd
endif

install:
ifeq ($(HAS_XINETD), 0)
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	cp xinetd-xinetd-$(XINETD)/xinetd/xinetd \
	    $(DESTDIR)$(OMD_ROOT)/bin
endif

skel:

clean:
ifeq ($(HAS_XINETD), 0)
	rm -rf xinetd-xinetd-$(XINETD)
endif
