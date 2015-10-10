include ../../Makefile.omd

.PHONY: skel

build:
	# Unpack source code, apply patches, call configure, call make

install:
	# Install software below $(DESTDIR)$(OMD_ROOT)/{bin,lib,share}

skel:
	! test -e /usr/share/mariadb/english || sed -e 's|/usr/share/mysql/english|/usr/share/mariadb/english|' -i ${SKEL}/.my.cnf

clean:
	# Remove files created by build/install
