include ../../Makefile.omd

NAME = nrpe
VERSION = 3.0.1
DIR = $(NAME)-$(VERSION)

.PHONY: skel

# Configure options for Nagios. Since we want to compile
# as non-root, we use our own user and group for compiling.
# All files will be packaged as user 'root' later anyway.
CONFIGUREOPTS = ""

build:
	tar xzf $(DIR).tar.gz
	cd $(DIR) ; patch -p0 < ../nrpe-0010-opensslv110-strict.patch.txt
	cd $(DIR) ; patch -p1 < ../0001-reduce-syslog-loglevels.patch
	cd $(DIR) ; CFLAGS=-DOPENSSL_NO_SSL2 ./configure $(CONFIGUREOPTS)
	$(MAKE) -C $(DIR) check_nrpe

install:
	install -m 755 $(DIR)/src/check_nrpe $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins
	
	mkdir $(DESTDIR)$(OMD_ROOT)/share/doc/nrpe
	install -m 644 $(DIR)/README.md   $(DESTDIR)$(OMD_ROOT)/share/doc/nrpe/README
	install -m 644 $(DIR)/LEGAL       $(DESTDIR)$(OMD_ROOT)/share/doc/nrpe/LEGAL
	install -m 644 $(DIR)/SECURITY.md $(DESTDIR)$(OMD_ROOT)/share/doc/nrpe/SECURITY

skel:

clean:
	rm -rf $(DIR)
