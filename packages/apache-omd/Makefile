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
	       $(SKEL)/etc/apache/apache.conf
	# UGLY: SLES needs mod_log_config.so to be loaded
	if [ $(DISTRO_NAME) = SLES ] ; then \
	    sed -i '/LoadModule python_module/iLoadModule log_config_module $(MODULE_DIR)/mod_log_config.so' $(SKEL)/etc/apache/apache.conf ; \
	fi
	sed -i 's|###APACHE_BIN###|$(APACHE_BIN)|g' $(SKEL)/etc/init.d/apache
	# Fix permissions
	chmod +x $(SKEL)/etc/init.d/apache
	# Create working directories
	mkdir -p $(SKEL)/var/log/apache
	mkdir -p $(SKEL)/var/www
	mkdir -p $(SKEL)/tmp/apache/run
	mkdir -p $(SKEL)/tmp/php/session

clean:
	# Remove files created by build/install
