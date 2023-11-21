include ../../../Makefile.omd

NAME     = check_testssl
VERSION  = 3.0.8

.PHONY: skel

build:
	cp bin/testssl.sh .
	for p in patches/*.patch ; do \
	    echo "applying $$p..." ; \
	    patch -p1 < $$p || exit 1; \
	done

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins
	install -m 755 check_testssl.sh $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins/
	install -m 755 testssl.sh $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins/

skel:

clean:
	rm -f ./testssl.sh

upstream:
	wget https://github.com/drwetter/testssl.sh/archive/refs/tags/v$(VERSION).tar.gz
	tar ozxf v$(VERSION).tar.gz
	rsync -a testssl.sh-$(VERSION)/testssl.sh testssl.sh
	rm -rf skel/etc/testssl
	mkdir -p skel/etc/testssl
	rsync -a testssl.sh-$(VERSION)/etc/. skel/etc/testssl/.
	ln -s . skel/etc/testssl/etc
	rm -rf testssl.sh-$(VERSION) v$(VERSION).tar.gz
