include ../../Makefile.omd

.PHONY: skel

SKEL_OPT=
ifeq ($(DISTRO_INFO),DEBIAN 9)
SKEL_OPT+=skel_enable_innodb
endif

build:
	# Unpack source code, apply patches, call configure, call make

install:
	# Install software below $(DESTDIR)$(OMD_ROOT)/{bin,lib,share}

skel: $(SKEL_OPT)
	! test -e /usr/share/mariadb/english || sed -e 's|/usr/share/mysql/english|/usr/share/mariadb/english|' -i ${SKEL}/.my.cnf

skel_enable_innodb:
	sed -e 's|^skip-innodb|#skip-innodb|' -i ${SKEL}/.my.cnf

clean:
	# Remove files created by build/install
