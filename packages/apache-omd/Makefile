include ../../Makefile.omd

NAME = apache-omd
VERSION = 1.0
DIR = $(NAME)-$(VERSION)

.PHONY: skel

build:
	# Unpack source code, apply patches, call configure, call make

install:
	# Install software below $(DESTDIR)$(OMD_ROOT)/{bin,lib,share}

skel:
	# Replace macros
	sed -i 's|###APACHE_MODULE_DIR###|$(APACHE_MODULE_DIR)|g' $(SKEL)/etc/apache/apache.conf
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
