include ../../../Makefile.omd

NAME     = check_testssl

.PHONY: skel

build:

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins
	install -m 755 check_testssl.sh $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins/
	install -m 755 testssl.sh $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins/

skel:

clean:

upstream:
	wget "https://testssl.sh" -O testssl.sh
	chmod 755 testssl.sh
	wget "https://testssl.sh/mapping-rfc.txt" -O mapping-rfc.txt
