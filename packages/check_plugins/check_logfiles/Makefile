include ../../../Makefile.omd

NAME = check_logfiles
VERSION = 3.11.0.2
DIR = $(NAME)-$(VERSION)

.PHONY: skel

# Configure options for Nagios. Since we want to compile
# as non-root, we use our own user and group for compiling.
# All files will be packaged as user 'root' later anyway.
CONFIGUREOPTS = ""

build:
	tar xzf $(DIR).tar.gz
	for i in configure.ac aclocal.m4 configure Makefile.am Makefile.in ; do \
	  test -f $(DIR)/$$i && touch $(DIR)/$$i ; \
	done
	cd $(DIR) ; ./configure $(CONFIGUREOPTS)
	$(MAKE) -C $(DIR)

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins
	install -m 755 $(DIR)/plugins-scripts/check_logfiles $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins/
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/check_logfiles
	cp check_logfiles.exe \
	    $(DESTDIR)$(OMD_ROOT)/share/check_logfiles

skel:

clean:
	rm -rf $(DIR)
