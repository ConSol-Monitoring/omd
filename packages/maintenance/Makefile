include ../../Makefile.omd

NAME = maintenance 
VERSION = $(OMD_VERSION)
SHELL = /bin/bash

build:

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 merge-crontabs 		$(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 logrotate 			$(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 list_swap_procs 		$(DESTDIR)$(OMD_ROOT)/bin

skel:

clean:
