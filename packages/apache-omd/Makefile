include ../../Makefile.omd

NAME = apache-omd
VERSION = 1.0
DIR = $(NAME)-$(VERSION)
FCGI_FILE="mod_fcgid-2.3.6"

MODULE_DIR=$(APACHE_MODULE_DIR)
ifeq ($(shell uname -m),x86_64)
  MODULE_DIR=$(APACHE_MODULE_DIR_64)
endif

APACHE_MODULES=
APACHE_MODULES_INSTALL=
APACHE_FCGID_PATH=$(MODULE_DIR)/$(APACHE_FCGID_MODULE)
ifeq ($(shell ../../distro),CENTOS 5.5)
  APACHE_MODULES=modfcgid
  APACHE_MODULES_INSTALL=modfcgid_install
  APACHE_FCGID_PATH=$(OMD_ROOT)/lib/apache/mod_fcgid.so
endif

.PHONY: skel

build: $(APACHE_MODULES)
	# Unpack source code, apply patches, call configure, call make

install: $(APACHE_MODULES_INSTALL)
	# Install software below $(DESTDIR)$(OMD_ROOT)/{bin,lib,share}
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/apache

skel:
	# Replace macros
	sed -i -e 's|###APACHE_MODULE_DIR###|$(MODULE_DIR)|g' \
	       -e 's|###APACHE_PHP_MODULE###|$(APACHE_PHP_MODULE)|g' \
	       -e 's|###APACHE_PYTHON_MODULE###|$(APACHE_PYTHON_MODULE)|g' \
	       $(SKEL)/etc/apache/apache.conf

	sed -i -e 's|###APACHE_FCGID_MODULE###|$(APACHE_FCGID_PATH)|g' \
	       $(SKEL)/etc/apache/conf.d/fcgid.conf

	sed -i 's|###APACHE_BIN###|$(APACHE_BIN)|g' $(SKEL)/etc/init.d/apache
	# Create working directories
	mkdir -p $(SKEL)/var/log/apache
	mkdir -p $(SKEL)/var/www
	mkdir -p $(SKEL)/tmp/apache/run
	mkdir -p $(SKEL)/tmp/php/session
	mkdir -p $(SKEL)/tmp/php/upload
	mkdir -p $(SKEL)/tmp/php/wsdl-cache

clean:
	# Remove files created by build/install

modfcgid:
	tar zxf $(FCGI_FILE).tar.gz
	patch -p0 < ./patches/0001-mod_fcgid.patch
	patch -p0 < ./patches/0002-mod_fcgid.patch
	cd $(FCGI_FILE) && ./configure.apxs
	$(MAKE) -C $(FCGI_FILE)

modfcgid_install:
	cp $(FCGI_FILE)/modules/fcgid/.libs/mod_fcgid.so $(DESTDIR)$(OMD_ROOT)/lib/apache
