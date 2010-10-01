include ../../Makefile.omd

NAME = nagios-plugins
VERSION = 1.4.15
DIR = $(NAME)-$(VERSION)

CONFIGUREOPTS = \
    --prefix=$(OMD_ROOT) \
    --libexecdir=$(OMD_ROOT)/lib/nagios/plugins

build:
	tar xzf $(DIR).tar.gz
	cd $(DIR) ; ./configure $(CONFIGUREOPTS)
	$(MAKE) -C $(DIR) all

install:
	$(MAKE) DESTDIR=$(DESTDIR) -C $(DIR) install
	# FIXME: pack these with SUID root
	install -m 755 $(DIR)/plugins-root/check_icmp $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins
	install -m 755 $(DIR)/plugins-root/check_dhcp $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins

	# Copy package documentations to have these information in the binary packages
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/doc/$(NAME)
	for file in ACKNOWLEDGEMENTS AUTHORS BUGS CODING COPYING FAQ LEGAL NEWS README REQUIREMENTS SUPPORT THANKS ; do \
	   mv $(DIR)/$$file $(DESTDIR)$(OMD_ROOT)/share/doc/$(NAME); \
	done

skel:

clean:
	rm -rf $(DIR)
