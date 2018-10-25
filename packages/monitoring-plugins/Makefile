include ../../Makefile.omd

NAME = monitoring-plugins
VERSION = master
DIR = $(NAME)-$(VERSION)
URIPARSER=0.8.6

CONFIGUREOPTS = \
    --prefix=$(OMD_ROOT) \
    --libexecdir=$(OMD_ROOT)/lib/nagios/plugins

build: uriparser
	rm -rf $(DIR)
	tar xzf $(DIR).tar.gz
	set -e ; for p in patches/*.patch ; do \
	    echo "applying $$p..." ; \
	    ( cd $(DIR) ; patch -p1 -b ) < $$p ; \
	done
	cd $(DIR) ; \
		URIPARSER="$(shell pwd)/uriparser-$(URIPARSER)/.libs/liburiparser.a" \
		URIPARSER_CPPFLAGS="-I$(shell pwd)/uriparser-$(URIPARSER)/include" \
		./configure $(CONFIGUREOPTS)
	$(MAKE) -C $(DIR) all

install:
	$(MAKE) DESTDIR=$(DESTDIR) -C $(DIR) install
	# FIXME: pack these with SUID root
	install -m 755 $(DIR)/plugins-root/check_icmp $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins
	install -m 755 $(DIR)/plugins-root/check_dhcp $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins
	ln -s check_icmp $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins/check_host

	# Copy package documentations to have these information in the binary packages
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/doc/$(NAME)
	for file in ACKNOWLEDGEMENTS AUTHORS CODING COPYING FAQ LEGAL NEWS README REQUIREMENTS SUPPORT THANKS ; do \
	   install -m 644 $(DIR)/$$file $(DESTDIR)$(OMD_ROOT)/share/doc/$(NAME); \
	done

	# link lib/nagios/plugins to lib/icinga/plugins
	if [ -d "$(DESTDIR)$(OMD_ROOT)/lib/icinga" ] ; then \
            cd $(DESTDIR)$(OMD_ROOT)/lib/icinga && ln -s ../nagios/plugins plugins ; \
	fi
	# link lib/nagios/plugins to lib/naemon/plugins
	if [ -d "$(DESTDIR)$(OMD_ROOT)/lib/naemon" ] ; then \
            cd $(DESTDIR)$(OMD_ROOT)/lib/naemon && ln -s ../nagios/plugins plugins ; \
	fi

uriparser:
	tar jxf uriparser-$(URIPARSER).tar.bz2
	cd uriparser-$(URIPARSER) && ./configure --disable-test --disable-doc && make

skel:

clean:
	rm -rf $(DIR)
	rm -rf uriparser-$(URIPARSER)
