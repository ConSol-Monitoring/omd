include ../../Makefile.omd

build:
	# Unpack source code, apply patches, call configure, call make
	sed -i 's|###APACHE_MODULE_DIR###|$(APACHE_MODULE_DIR)|g' skel/etc/apache/apache.conf

install:
	# Install software below $(DESTDIR)$(OMD_ROOT)/{bin,lib,share}

skel:
	# Optional target called to create additional files below skel
	mkdir -p skel/var/log/apache
	mkdir -p skel/tmp/apache/run

clean:
	# Remove files created by build/install
