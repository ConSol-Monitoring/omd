include ../../Makefile.omd

XINETD=2-3-15
SLES15 = $(shell echo $(DISTRO_INFO) | grep -c 'SLES 15' )

build:
ifeq ($(SLES15), 1)
	tar xvzf xinetd-$(XINETD).tar.gz
	cd xinetd-xinetd-$(XINETD) && \
	    ./configure; \
	    make; \
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
