include ../../Makefile.omd

NAME = apache-omd
VERSION = 1.0
DIR = $(NAME)-$(VERSION)
ifeq ($(shell uname -m),x86_64)
  MODULE_DIR=$(APACHE_MODULE_DIR_64)
else
  MODULE_DIR=$(APACHE_MODULE_DIR)
endif

.PHONY: skel

build:
	# Unpack source code, apply patches, call configure, call make

install:
	# Install software below $(DESTDIR)$(OMD_ROOT)/{bin,lib,share}

skel:
	# Replace macros
	sed -i -e 's|###APACHE_MODULE_DIR###|$(MODULE_DIR)|g' \
	       -e 's|###APACHE_PHP_MODULE###|$(APACHE_PHP_MODULE)|g' \
	       -e 's|###APACHE_PYTHON_MODULE###|$(APACHE_PYTHON_MODULE)|g' \
	       -e 's|###APACHE_FCGID_MODULE###|$(APACHE_FCGID_MODULE)|g' \
	       $(SKEL)/etc/apache/apache.conf
	sed -i 's|###APACHE_BIN###|$(APACHE_BIN)|g' $(SKEL)/etc/init.d/apache
	# Fix permissions
	chmod +x $(SKEL)/etc/init.d/apache
	# Create working directories
	mkdir -p $(SKEL)/var/log/apache
	mkdir -p $(SKEL)/var/www
	mkdir -p $(SKEL)/tmp/apache/run
	mkdir -p $(SKEL)/tmp/php/session
	mkdir -p $(SKEL)/tmp/php/upload
	mkdir -p $(SKEL)/tmp/php/wsdl-cache

clean:
	# Remove files created by build/install
