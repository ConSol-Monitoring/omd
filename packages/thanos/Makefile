include ../../Makefile.omd

NAME       = thanos
VERSION    = 0.4.0

.PHONY: skel

build:

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 get_thanos $(DESTDIR)$(OMD_ROOT)/bin
	sed -i 's|###VERSION###|$(VERSION)|g' $(DESTDIR)$(OMD_ROOT)/bin/get_thanos

skel:

clean:
