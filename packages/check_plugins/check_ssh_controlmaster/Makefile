include ../../../Makefile.omd

NAME = check_ssh_controlmaster
VERSION = 1.0
DIR = $(NAME)-$(VERSION)

.PHONY: skel


build:

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins
	install -m 755 check_ssh_controlmaster $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins

skel:

clean:
