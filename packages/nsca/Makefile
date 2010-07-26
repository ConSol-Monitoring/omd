include ../../Makefile.omd

NAME = nsca
VERSION = 2.7.2
DIR = $(NAME)-$(VERSION)

.PHONY: skel

# Configure options for Nagios. Since we want to compile
# as non-root, we use our own user and group for compiling.
# All files will be packaged as user 'root' later anyway.
CONFIGUREOPTS = ""

build:
	tar xzf $(DIR).tar.gz
	cd $(DIR) ; ./configure $(CONFIGUREOPTS)
	$(MAKE) -C $(DIR) all

install:
	install -m 755 $(DIR)/src/nsca $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(DIR)/src/send_nsca $(DESTDIR)$(OMD_ROOT)/bin

skel:

clean:
	rm -rf $(DIR)
