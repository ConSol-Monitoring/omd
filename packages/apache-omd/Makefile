include ../../Makefile.omd

NAME = apache-omd
VERSION = 1.0
DIR = $(NAME)-$(VERSION)
FCGI_FILE="mod_fcgid-2.3.9"
MOD_RPAF_VERSION="0.8"
MOD_PROMETHEUS_STATUS_VERSION="0.0.6"

GOPKG       = 1.14
GOVERSION   = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')

APACHE_MODULES=modrpaf modprometheus_status
APACHE_MODULES_INSTALL=modrpaf_install modprometheus_status_install
APACHE_FCGID_PATH=$(MODULE_DIR)/$(APACHE_FCGID_MODULE)
INSTALL_FCGID=0

# Try to find the apxs binary
APXS=/usr/sbin/apxs
ifeq ("$(wildcard $(APXS))","")
    APXS=apxs
endif
ifneq ("$(wildcard /usr/sbin/apxs2)","")
    APXS=/usr/sbin/apxs2
endif

ifeq ($(DISTRO_NAME),SLES)
  ifneq (,$(findstring 12SP,$(DISTRO_VERSION)))
    INSTALL_FCGID=1
  endif
endif

ifeq ($(INSTALL_FCGID), 1)
  APACHE_MODULES+=modfcgid
  APACHE_MODULES_INSTALL+=modfcgid_install
  APACHE_FCGID_PATH=$(OMD_ROOT)/lib/apache/mod_fcgid.so
endif

.PHONY: skel

build: $(APACHE_MODULES)

install: $(APACHE_MODULES_INSTALL)
	# Install software below $(DESTDIR)$(OMD_ROOT)/{bin,lib,share}
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/omd
	if [ $(APACHE_24_OR_NEWER) -eq 1 ]; then \
		install -m 644 apache24.conf $(DESTDIR)$(OMD_ROOT)/share/omd/apache.conf; \
	else \
		install -m 644 apache.conf $(DESTDIR)$(OMD_ROOT)/share/omd/apache.conf; \
	fi

skel:
	# install a custom apache configuration for apache 2.4 or later
	if [ $(APACHE_24_OR_NEWER) -eq 1 ]; then \
	    mv $(SKEL)/etc/apache/apache24.conf $(SKEL)/etc/apache/apache.conf ; \
	else \
	    rm $(SKEL)/etc/apache/apache24.conf ; \
	fi

	# Replace macros
	sed -i -e 's|###APACHE_MODULE_DIR###|$(MODULE_DIR)|g' \
	       $(SKEL)/etc/apache/conf.d/01_rpaf.conf \
	       $(SKEL)/etc/apache/apache.conf \
	       $(SKEL)/etc/apache/apache-ssl.conf

	# SLES12 has apache 2.4 but does not have the prefork module to be loaded,
	# so remove this load line for this distro from the apache config
	if [ ! -e $(MODULE_DIR)/mod_mpm_prefork.so ]; then \
	    sed -i '/^LoadModule mpm_prefork_module/d' $(SKEL)/etc/apache/apache.conf ; \
	fi

	sed -i -e 's|###APACHE_FCGID_MODULE###|$(APACHE_FCGID_PATH)|g' \
	       $(SKEL)/etc/apache/conf.d/02_fcgid.conf

	sed -i 's|###APACHE_BIN###|$(APACHE_BIN)|g' $(SKEL)/etc/init.d/apache
	sed -i 's|###PHP_FCGI_BIN###|$(PHP_FCGI_BIN)|g' $(SKEL)/etc/init.d/apache $(SKEL)/etc/apache/php-wrapper
	# Create working directories
	mkdir -p $(SKEL)/var/log/apache
	mkdir -p $(SKEL)/var/www
	mkdir -p $(SKEL)/tmp/apache/run
	mkdir -p $(SKEL)/tmp/apache/fcgid_sock
	mkdir -p $(SKEL)/tmp/php/session
	mkdir -p $(SKEL)/tmp/php/upload
	mkdir -p $(SKEL)/tmp/php/wsdl-cache

	# install example dashboard
	mkdir -p $(SKEL)/etc/grafana/examples/
	install -m 644 mod_prometheus_status-$(MOD_PROMETHEUS_STATUS_VERSION)/Apache-Dashboard.json $(SKEL)/etc/grafana/examples/apache.json

clean:
	# Remove files created by build/install
	rm -rf $(FCGI_FILE)
	rm -rf mod_rpaf-$(MOD_RPAF_VERSION)
	rm -rf mod_prometheus_status-$(MOD_PROMETHEUS_STATUS_VERSION)

modfcgid:
	tar zxf $(FCGI_FILE).tar.gz
	cd $(FCGI_FILE) && patch -p1 < ../patches/0001-fcgid_proc_unix.c.patch
	cd $(FCGI_FILE) && patch -p1 < ../patches/0002-fcgid_pm_unix.c.patch
	cd $(FCGI_FILE) && patch -p1 < ../patches/30_fix-bts-691929.patch
	cd $(FCGI_FILE) && patch -p1 < ../patches/40_fix_loading_large_requests.patch
	cd $(FCGI_FILE) && APXS=$(APXS) ./configure.apxs
	CPATH="/usr/include/apache2-worker" $(MAKE) -C $(FCGI_FILE)

modfcgid_install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/apache
	cp $(FCGI_FILE)/modules/fcgid/.libs/mod_fcgid.so $(DESTDIR)$(OMD_ROOT)/lib/apache/

modrpaf:
	tar zxf mod_rpaf-$(MOD_RPAF_VERSION).tar.gz
	make -C mod_rpaf-$(MOD_RPAF_VERSION)

modrpaf_install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/apache
	cp mod_rpaf-$(MOD_RPAF_VERSION)/.libs/mod_rpaf.so $(DESTDIR)$(OMD_ROOT)/lib/apache/

modprometheus_status:
	tar zxf mod_prometheus_status-$(MOD_PROMETHEUS_STATUS_VERSION).tar.gz
	PATH=$(shell pwd)/../go-$(GOPKG)/go-$(GOVERSION)/bin:$$PATH \
		make -C mod_prometheus_status-$(MOD_PROMETHEUS_STATUS_VERSION)

modprometheus_status_install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/apache
	cp mod_prometheus_status-$(MOD_PROMETHEUS_STATUS_VERSION)/mod_prometheus_status*.so $(DESTDIR)$(OMD_ROOT)/lib/apache/
