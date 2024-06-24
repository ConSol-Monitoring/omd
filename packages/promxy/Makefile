include ../../Makefile.omd

NAME       = promxy
VERSION    = v0.0.86

.PHONY: skel

get_promxy: get_promxy.in
	sed 's|###VERSION###|$(VERSION)|g' get_promxy.in > get_promxy

build: get_promxy

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 get_promxy $(DESTDIR)$(OMD_ROOT)/bin

skel:

clean:
	rm -f get_promxy
