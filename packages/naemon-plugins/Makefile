include ../../Makefile.omd

NAME    = naemon-vimvault
VERSION = 1.3.0
DIR     = $(NAME)-$(VERSION)
DEPENDS = naemon

CONFIGUREOPTS = \
    --libdir=$(OMD_ROOT)/lib \
    --prefix=$(OMD_ROOT)

build:
	tar xzf $(NAME)-$(VERSION).tar.gz
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

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/naemon
	install -m 755 $(DIR)/.libs/naemon_vimvault.so $(DESTDIR)$(OMD_ROOT)/lib/naemon/vimvault.o.dbg
	install -sm 755 $(DIR)/.libs/naemon_vimvault.so $(DESTDIR)$(OMD_ROOT)/lib/naemon/vimvault.o

skel:

clean:
	rm -rf $(DIR)

upstream:
	rm -f *.gz
	wget https://github.com/naemon/naemon-vimcrypt-vault-broker/tarball/master -O tmp.tar.gz
	tar zxf tmp.tar.gz
	mv naemon-naemon-vimcrypt-vault-broker-??????? naemon-vimcrypt-vault-broker-master
	cd naemon-vimcrypt-vault-broker-master && autoreconf -i && ./configure && make dist && mv *.gz ..
	rm -rf tmp.tar.gz naemon-vimcrypt-vault-broker-master
	tar zxf naemon_vimvault_neb-*.tar.gz
	rm naemon_vimvault_neb-*.tar.gz
	mv naemon_vimvault_neb-* naemon_vimvault_neb-master
	tar cfz naemon_vimvault_neb-master.tar.gz naemon_vimvault_neb-master
	rm -rf naemon_vimvault_neb-master
