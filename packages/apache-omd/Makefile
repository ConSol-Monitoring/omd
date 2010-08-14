include ../../Makefile.omd

build:
	# Unpack source code, apply patches, call configure, call make
	sed 's|###APACHE_MODULE_DIR###|$(APACHE_MODULE_DIR)|g' skel/etc/apache/apache.conf.in > skel/etc/apache/apache.conf
	sed 's|###APACHE_BIN###|$(APACHE_BIN)|g' skel/etc/init.d/apache.in > skel/etc/init.d/apache
	chmod +x skel/etc/init.d/apache
	
	#rm skel/etc/apache/apache.conf.in
	#rm skel/etc/init.d/apache.in
	mkdir -p skel/var/log/apache
	mkdir -p skel/var/www
	mkdir -p skel/tmp/apache/run
	mkdir -p skel/tmp/php/session

install:
	# Install software below $(DESTDIR)$(OMD_ROOT)/{bin,lib,share}

skel:
	# Optional target called to create additional files below skel

clean:
	# Remove files created by build/install
	rm -f skel/etc/init.d/apache
	rm -f skel/etc/apache/apache.conf
