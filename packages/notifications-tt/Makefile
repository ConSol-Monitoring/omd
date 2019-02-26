include ../../Makefile.omd

NAME     = notifications-tt
VERSION  = 1

.PHONY: skel

build:

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins
	install -m 755 notify-by-email.pl $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins/notify-by-email.pl

skel:

clean:
