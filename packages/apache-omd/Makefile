include ../../Makefile.omd

build:
	# Unpack source code, apply patches, call configure, call make
	sed 's|###APACHE_MODULE_DIR###|$(APACHE_MODULE_DIR)|g' skel/etc/apache/apache.conf.in > skel/etc/apache/apache.conf
	rm skel/etc/apache/apache.conf.in
	mkdir -p skel/var/log/apache
	mkdir -p skel/tmp/apache/run

install:
	# Install software below $(DESTDIR)$(OMD_ROOT)/{bin,lib,share}

skel:
	# Optional target called to create additional files below skel

clean:
	# Remove files created by build/install
