include ../../Makefile.omd

XINETD=2-3-15
SLES15 = $(shell echo $(DISTRO_INFO) | grep -c 'SLES 15' )
SLES15SP3 = $(shell echo $(DISTRO_INFO) | grep -c 'SLES 15SP3' )

ifeq ($(SLES15SP3), 1)
LDFLAGS = "-ltirpc"
else
LDFLAGS = ""
endif

build:
ifeq ($(SLES15), 1)
	tar xvzf xinetd-$(XINETD).tar.gz
	cd xinetd-xinetd-$(XINETD) && \
	    ./configure; \
	    make LDFLAGS=$(LDFLAGS); \
	    strip xinetd/xinetd
endif

install:
ifeq ($(SLES15), 1)
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	cp xinetd-xinetd-$(XINETD)/xinetd/xinetd \
	    $(DESTDIR)$(OMD_ROOT)/bin
endif

skel:

clean:
ifeq ($(SLES15), 1)
	rm -rf xinetd-xinetd-$(XINETD)
endif
