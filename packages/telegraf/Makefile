include ../../Makefile.omd

NAME       = telegraf
VERSION    = 1.28.2

.PHONY: skel

get_telegraf: get_telegraf.in
	sed 's|###VERSION###|$(VERSION)|g' get_telegraf.in > get_telegraf

build: get_telegraf

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 get_telegraf $(DESTDIR)$(OMD_ROOT)/bin

skel:

clean:
	rm -f get_telegraf
