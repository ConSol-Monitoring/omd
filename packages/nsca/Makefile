include ../../Makefile.omd

NAME = nsca
VERSION = 2.10.2
DIR = $(NAME)-$(VERSION)

.PHONY: skel

# Configure options for Nagios. Since we want to compile
# as non-root, we use our own user and group for compiling.
# All files will be packaged as user 'root' later anyway.
CONFIGUREOPTS = ""

RUN_AUTOMAKE=0
ifeq ($(shell uname -m),aarch64)
RUN_AUTOMAKE=1
endif

build:
	tar xzf $(DIR).tar.gz
	-if [ "x$(RUN_AUTOMAKE)" = "x1" ]; then cd $(DIR) && automake -af; fi
	cd $(DIR) && ./configure $(CONFIGUREOPTS)
	$(MAKE) -C $(DIR) all

install:
	install -m 755 $(DIR)/src/nsca $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(DIR)/src/send_nsca $(DESTDIR)$(OMD_ROOT)/bin

	mkdir $(DESTDIR)$(OMD_ROOT)/share/doc/nsca
	install -m 644 $(DIR)/README.md $(DESTDIR)$(OMD_ROOT)/share/doc/nsca
	install -m 644 $(DIR)/LICENSE.md $(DESTDIR)$(OMD_ROOT)/share/doc/nsca
	install -m 644 $(DIR)/SECURITY.md $(DESTDIR)$(OMD_ROOT)/share/doc/nsca

skel:

clean:
	rm -rf $(DIR)
