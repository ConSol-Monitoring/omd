include ../../Makefile.omd

NAME = monitoring-plugins
CHANGELOG = https://github.com/monitoring-plugins/monitoring-plugins/blob/master/NEWS
VERSION = master
DIR = $(NAME)-$(VERSION)
URIPARSER=0.8.6
# GIT TAG is set automatically by "make upstream"
GIT_TAG     = 9bf8c49

BUILD=build-plugins
INSTALL=install-plugins
ifeq ($(DISTRO_CODE),el7)
BUILD=build-skip
INSTALL=install-skip
endif

CONFIGUREOPTS = \
    --prefix=$(OMD_ROOT) \
    --without-radius \
    --libexecdir=$(OMD_ROOT)/lib/monitoring-plugins/v3

CFLAGS += -fpie

build: $(BUILD)

build-skip:

build-plugins: uriparser-$(URIPARSER)
	rm -rf $(DIR)
	tar xzf $(DIR).tar.gz --no-same-owner
	#set -e ; for p in patches/*.patch $(EXTRA_PATCHES); do \
	#    echo "applying $$p..." ; \
	#    ( cd $(DIR) ; patch -p1 -b ) < $$p ; \
	#done
	sed -e 's/\.git/_$(shell date +%F)_$(GIT_TAG)/g' -i $(DIR)/NP-VERSION-GEN
	rm -f $(DIR)/release
	cd $(DIR) && \
		URIPARSER="$(shell pwd)/uriparser-$(URIPARSER)/.libs/liburiparser.a" \
		URIPARSER_CPPFLAGS="-I$(shell pwd)/uriparser-$(URIPARSER)/include" \
		CFLAGS="$(CFLAGS)" ./configure $(CONFIGUREOPTS)
	CFLAGS="$(CFLAGS)" $(MAKE) -C $(DIR) all

install: $(INSTALL)

install-skip:

install-plugins:
	$(MAKE) DESTDIR=$(DESTDIR) -C $(DIR) install
	install -m 755 $(DIR)/plugins-root/check_icmp $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins/v3
	install -m 755 $(DIR)/plugins-root/check_dhcp $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins/v3
	ln -s check_icmp $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins/v3/check_host

uriparser-$(URIPARSER):
	tar jxf uriparser-$(URIPARSER).tar.bz2 --no-same-owner
	cd uriparser-$(URIPARSER) && ./configure --disable-test --disable-doc && make

skel:

clean:
	rm -rf $(DIR)
	rm -rf uriparser-$(URIPARSER)

upstream:
	git clone --depth=1 https://github.com/monitoring-plugins/monitoring-plugins monitoring-plugins-master
	cd monitoring-plugins-master/ \
		&& ./autogen.sh \
		&& sed -i $(PWD)/Makefile -e 's/^GIT_TAG.*$$/GIT_TAG     = '$$(git describe --always --tags)'/g'
	tar cvfz monitoring-plugins-master.tar.gz monitoring-plugins-master
	rm -rf monitoring-plugins-master
	rm -rf master.tar.gz
