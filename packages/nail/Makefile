include ../../Makefile.omd

NAME     = nail
VERSION  = 11.25
DIR      = nail-$(VERSION)

.PHONY: skel

build:
	tar xjf nail-$(VERSION).tar.bz2
	set -e ; for p in patches/*.dif ; do \
	    echo "applying $$p..." ; \
	    ( cd $(DIR) ; patch -p1 -b ) < $$p ; \
	done
	cd $(DIR) && $(MAKE) -j 1

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(DIR)/nail $(DESTDIR)$(OMD_ROOT)/bin/nail
	ln -sfn nail $(DESTDIR)$(OMD_ROOT)/bin/mail
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/man/man1
	install -m 644 $(DIR)/nail.1 $(DESTDIR)$(OMD_ROOT)/share/man/man1/nail.1
	gzip $(DESTDIR)$(OMD_ROOT)/share/man/man1/nail.1

skel:

clean:
	rm -rf $(DIR)
