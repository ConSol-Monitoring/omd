include ../../Makefile.omd

NAME       = thanos
VERSION    = 0.10.1

.PHONY: skel

get_thanos: get_thanos.in
	sed 's|###VERSION###|$(VERSION)|g' get_thanos.in > get_thanos

build: get_thanos

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 get_thanos $(DESTDIR)$(OMD_ROOT)/bin

skel:

clean:
	rm -f get_thanos
