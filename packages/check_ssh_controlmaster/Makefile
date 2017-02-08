include ../../Makefile.omd

NAME = check_ssh_controlmaster
VERSION = 1.0
DIR = $(NAME)-$(VERSION)

.PHONY: skel


build:

install:
	[ -d $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins ] || mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins
	install -m 755 check_ssh_controlmaster $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins

skel:

clean:
