include ../../Makefile.omd

NAME = omd
VERSION = $(OMD_VERSION)
SHELL = /bin/bash

build:

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 omd $(DESTDIR)$(OMD_ROOT)/bin
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/omd/htdocs
	install -m 644 index.php $(DESTDIR)$(OMD_ROOT)/share/omd/htdocs
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/man/man8
	install -m 644 omd.8 $(DESTDIR)$(OMD_ROOT)/share/man/man8
	gzip $(DESTDIR)$(OMD_ROOT)/share/man/man8/omd.8
	install -m 755 omd.init $(DESTDIR)$(OMD_ROOT)/share/omd/omd.init
	install -m 644 apache.conf $(DESTDIR)$(OMD_ROOT)/share/omd/apache.conf

skel:

clean:
