include ../../Makefile.omd

NAME = omd
VERSION = $(OMD_VERSION)
SHELL = /bin/bash

build:

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 omd $(DESTDIR)$(OMD_ROOT)/bin
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/omd/htdocs
	install -m 644 index.py $(DESTDIR)$(OMD_ROOT)/share/omd/htdocs
	install -m 644 logout.php $(DESTDIR)$(OMD_ROOT)/share/omd/htdocs
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/omd/htdocs/img
	install -m 644 img/* $(DESTDIR)$(OMD_ROOT)/share/omd/htdocs/img
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/man/man8
	install -m 644 omd.8 $(DESTDIR)$(OMD_ROOT)/share/man/man8
	gzip $(DESTDIR)$(OMD_ROOT)/share/man/man8/omd.8
	install -m 755 omd.init $(DESTDIR)$(OMD_ROOT)/share/omd/omd.init
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/doc/$(NAME)
	install -m 644 COPYING AUTHORS $(DESTDIR)$(OMD_ROOT)/share/doc/$(NAME)
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/omd
	install -m 644 init_profile $(DESTDIR)$(OMD_ROOT)/lib/omd/
	
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/omd/scripts/post-create

skel:

clean:
