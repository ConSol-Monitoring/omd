include ../../Makefile.omd

PUSHGATEWAY=pushgateway-0.3.0

.PHONY: skel

build:
	tar xzf $(PUSHGATEWAY).linux-amd64.tar.gz

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(PUSHGATEWAY).linux-amd64/pushgateway $(DESTDIR)$(OMD_ROOT)/bin

skel:

clean:
	rm -rf $(PUSHGATEWAY).linux-amd64
