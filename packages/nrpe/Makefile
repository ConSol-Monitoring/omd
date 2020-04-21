include ../../Makefile.omd

NAME = nrpe
VERSION = 4.0.2
DIR = $(NAME)-$(VERSION)

.PHONY: skel

# Configure options for Nagios. Since we want to compile
# as non-root, we use our own user and group for compiling.
# All files will be packaged as user 'root' later anyway.
CONFIGUREOPTS = ""

build:
	tar xzf $(DIR).tar.gz
	set -e ; for p in patches/*.patch ; do \
	    echo "applying $$p..." ; \
	    ( cd $(DIR) ; patch -p1 -b ) < $$p ; \
	done
	cd $(DIR) ; CFLAGS=-DOPENSSL_NO_SSL2 ./configure $(CONFIGUREOPTS)
	$(MAKE) -C $(DIR) check_nrpe

install:
	install -m 755 $(DIR)/src/check_nrpe $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins
	
	mkdir $(DESTDIR)$(OMD_ROOT)/share/doc/nrpe
	install -m 644 $(DIR)/*.md  $(DESTDIR)$(OMD_ROOT)/share/doc/nrpe
	install -m 644 $(DIR)/LEGAL $(DESTDIR)$(OMD_ROOT)/share/doc/nrpe/LEGAL

skel:

clean:
	rm -rf $(DIR)
