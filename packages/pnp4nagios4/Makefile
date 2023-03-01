include ../../Makefile.omd
include ../pnp4nagios/Makefile
DEPENDS = naemon pnp4nagios

.PHONY: skel

build:
	tar xzf ../pnp4nagios/$(DIR).tar.gz
	set -e; \
	for p in ../pnp4nagios/patches/*.patch ; do \
	    echo "applying $$p..." ; \
	    ( cd $(DIR) ; patch -p1 ) < $$p || exit 1; \
	done
	for p in patches/*.patch ; do \
	    echo "applying $$p..." ; \
	    ( cd $(DIR) ; patch -p1 ) < $$p || exit 1; \
	done
	find $(DIR) -name \*.orig -exec rm {} \;
	-if [ "x$(RUN_AUTOMAKE)" = "x1" ]; then cd $(DIR) && automake -af; fi
	cd $(DIR) ; \
		LIBS="$(shell PKG_CONFIG_PATH="`ls -d1 ../naemon/naemon-*/.`" pkg-config --libs-only-L naemon-uninstalled)" \
		CFLAGS="$(shell PKG_CONFIG_PATH="`ls -d1 ../naemon/naemon-*/.`" pkg-config --cflags naemon-uninstalled)" \
		./configure $(CONFIGUREOPTS)
	cd $(DIR) && mv include include.orig && cp -rp ../../naemon/naemon-*/src/naemon include
	cd $(DIR) && cp -rp ../../naemon/naemon-*/lib include/
	cd $(DIR)/include && cp ../../../naemon/naemon-*/config.h .
	cd $(DIR)/include && cp ../include.orig/pnp.* ../include.orig/npcdmod.h .
	cd $(DIR)/src && sed -e 's/service_check_command/check_command/' -e 's/host_check_command/check_command/' -i npcdmod.c ../include/objects.h
	$(MAKE) -C $(DIR)/src npcdmod.o

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib
	cp $(DIR)/src/npcdmod.o $(DESTDIR)$(OMD_ROOT)/lib/npcdmod4.o

skel:
	mkdir -p $(SKEL)/etc/pnp4nagios
	sed -e 's/npcdmod.o/npcdmod4.o/g' $(SKEL)/etc/pnp4nagios/nagios_npcdmod.cfg > $(SKEL)/etc/pnp4nagios/naemon_npcdmod.cfg
