include ../../Makefile.omd

NAME = monitoring-plugins
VERSION = 2.3.1
master  = feature_check_curl
DIR = $(NAME)-$(VERSION)
URIPARSER=0.8.6
# GIT TAG is set automatically by "make upstream"
GIT_TAG     = bc6eeb

CONFIGUREOPTS = \
    --prefix=$(OMD_ROOT) \
    --libexecdir=$(OMD_ROOT)/lib/monitoring-plugins

build: uriparser
	rm -rf $(DIR)
	tar xzf $(DIR).tar.gz
	set -e ; for p in patches/*.patch ; do \
	    echo "applying $$p..." ; \
	    ( cd $(DIR) ; patch -p1 -b ) < $$p ; \
	done
	sed -e 's/\.git/_$(shell date +%F)_$(GIT_TAG)/g' -i $(DIR)/NP-VERSION-GEN
	rm -f $(DIR)/release
	cd $(DIR) && \
		URIPARSER="$(shell pwd)/uriparser-$(URIPARSER)/.libs/liburiparser.a" \
		URIPARSER_CPPFLAGS="-I$(shell pwd)/uriparser-$(URIPARSER)/include" \
		./configure $(CONFIGUREOPTS)
	$(MAKE) -C $(DIR) all

install:
	$(MAKE) DESTDIR=$(DESTDIR) -C $(DIR) install
	# FIXME: pack these with SUID root
	install -m 755 $(DIR)/plugins-root/check_icmp $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins
	install -m 755 $(DIR)/plugins-root/check_dhcp $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins
	ln -s check_icmp $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins/check_host

	# Copy package documentations to have these information in the binary packages
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/doc/$(NAME)
	set -e; for file in ACKNOWLEDGEMENTS AUTHORS CODING COPYING FAQ NEWS README REQUIREMENTS SUPPORT; do \
	   install -m 644 $(DIR)/$$file $(DESTDIR)$(OMD_ROOT)/share/doc/$(NAME); \
	done

	# link lib/monitoring-plugins to lib/nagios/plugins
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/nagios
	cd $(DESTDIR)$(OMD_ROOT)/lib/nagios && ln -s ../monitoring-plugins plugins

uriparser:
	tar jxf uriparser-$(URIPARSER).tar.bz2
	cd uriparser-$(URIPARSER) && ./configure --disable-test --disable-doc && make

skel:

clean:
	rm -rf $(DIR)
	rm -rf uriparser-$(URIPARSER)

upstream:
	git clone --depth=1 -b $(BRANCH) https://github.com/monitoring-plugins/monitoring-plugins monitoring-plugins-master
	cd monitoring-plugins-master/ \
		&& ./autogen.sh \
		&& sed -i $(PWD)/Makefile -e 's/^GIT_TAG.*$$/GIT_TAG     = '$$(git describe --always --tags)'/g'
	tar cvfz monitoring-plugins-master.tar.gz monitoring-plugins-master
	rm -rf monitoring-plugins-master
	rm -rf master.tar.gz
