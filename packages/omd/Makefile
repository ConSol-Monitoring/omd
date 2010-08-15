include ../../Makefile.omd

NAME = omd
VERSION = $(OMD_VERSION)
SHELL = /bin/bash

build:

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 omd $(DESTDIR)$(OMD_ROOT)/bin
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/omd/htdocs
	install -m 755 index.php $(DESTDIR)$(OMD_ROOT)/share/omd/htdocs

skel:

clean:
