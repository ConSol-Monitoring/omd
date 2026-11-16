include ../../Makefile.omd

NAME    = naemon-vimvault
CHANGELOG = https://github.com/naemon/naemon-vimcrypt-vault-broker/blob/master/ChangeLog
VERSION = 1.6.0
DIR     = $(NAME)-$(VERSION)
DEPENDS = naemon

CONFIGUREOPTS = \
    --libdir=$(OMD_ROOT)/lib \
    --prefix=$(OMD_ROOT)

build:
	tar xfJ $(NAME)-$(VERSION).tar.xz
	cd $(DIR); \
		export PKG_CONFIG_PATH="$(shell pwd)/$(shell ls -d1 ../naemon/naemon-*/.)"; \
		autoreconf -s; \
		automake --add-missing; \
		NAEMON_LIBS="$(shell PKG_CONFIG_PATH=`ls -d1 ../naemon/naemon-*/.` pkg-config --libs naemon-uninstalled)" \
		NAEMON_CFLAGS="$(shell PKG_CONFIG_PATH=`ls -d1 ../naemon/naemon-*/.` pkg-config --cflags naemon-uninstalled)" \
		 ./configure $(CONFIGUREOPTS)
	rm -f $(DIR)/lib $(DIR)/naemon
	cd $(DIR) && src=`ls -d1 ../../naemon/naemon-*/src/naemon` && ln -s $$src naemon
	cd $(DIR) && lib=`ls -d1 ../../naemon/naemon-*/lib` && ln -s $$lib lib
	$(MAKE) -C $(DIR) all
	cp $(DIR)/.libs/naemon_vimvault.so $(DIR)/.libs/naemon_vimvault.so.dbg

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/naemon
	install -m 755 $(DIR)/.libs/naemon_vimvault.so.dbg $(DESTDIR)$(OMD_ROOT)/lib/naemon/vimvault.o.dbg
	install -sm 755 $(DIR)/.libs/naemon_vimvault.so    $(DESTDIR)$(OMD_ROOT)/lib/naemon/vimvault.o
	install -m 755 cat_naemonvault $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 vim_naemonvault $(DESTDIR)$(OMD_ROOT)/bin

skel:

clean:
	rm -rf $(DIR)

upstream:
	rm -f *.gz *.tar.xz
	wget https://github.com/naemon/naemon-vimcrypt-vault-broker/tarball/master -O tmp.tar.gz
	tar zxf tmp.tar.gz
	mv naemon-naemon-vimcrypt-vault-broker-??????? naemon-vimcrypt-vault-broker-master
	cd naemon-vimcrypt-vault-broker-master && \
		export PKG_CONFIG_PATH="`ls -d1 $(CURDIR)/../naemon/naemon-*/.`" ; \
		autoreconf -i && ./configure && make dist && mv *.gz ..
	rm -rf tmp.tar.gz naemon-vimcrypt-vault-broker-master
	tar zxf $(NAME)-$(VERSION).tar.gz
	rm $(NAME)-$(VERSION).tar.gz
	tar cf $(DIR).tar $(DIR)
	xz -9 $(DIR).tar
	rm -rf $(DIR)

# Repack a release tag and update VERSION: make upstream-release VERSION=1.5.1
upstream-release:
	@test -n "$(VERSION)" || { echo "usage: make upstream-release VERSION=x.y.z"; exit 1; }
	rm -f $(DIR).tar.xz
	wget "https://github.com/naemon/naemon-vimcrypt-vault-broker/archive/refs/tags/v$(VERSION).tar.gz" -O tmp.tar.gz
	tar zxf tmp.tar.gz
	mv naemon-vimcrypt-vault-broker-$(VERSION) $(DIR)
	cd $(DIR) && autoreconf -i && rm -rf autom4te.cache
	XZ_OPT=-8 tar cfJ $(DIR).tar.xz $(DIR)
	sed -i "s/^VERSION = .*/VERSION = $(VERSION)/" Makefile
	git add Makefile $(DIR).tar.xz
	rm -rf $(DIR) tmp.tar.gz
