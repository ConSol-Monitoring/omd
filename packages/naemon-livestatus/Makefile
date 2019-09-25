include ../../Makefile.omd

NAME = naemon-livestatus
VERSION = 1.1.0
DIR = $(NAME)-$(VERSION)

CONFIGUREOPTS = \
    --prefix=$(OMD_ROOT)

build:
	tar xzf $(NAME)-$(VERSION).tar.gz
	#set -e ; for p in patches/*.patch ; do \
	#    echo "applying $$p..." ; \
	#    ( cd $(DIR) ; patch -p1 -b ) < $$p ; \
	#done
	cd $(DIR); \
		autoreconf -s; \
		automake --add-missing; \
		NAEMON_LIBS="$(shell PKG_CONFIG_PATH="`ls -d1 ../naemon/naemon-*/.`" pkg-config --libs naemon-uninstalled)" \
		NAEMON_CFLAGS="$(shell PKG_CONFIG_PATH="`ls -d1 ../naemon/naemon-*/.`" pkg-config --cflags naemon-uninstalled)" \
		 ./configure $(CONFIGUREOPTS)
	rm -f $(DIR)/src/lib $(DIR)/src/naemon
	cd $(DIR)/src && src=`ls -d1 ../../../naemon/naemon-*/src/naemon` && ln -s $$src naemon
	cd $(DIR)/src && lib=`ls -d1 ../../../naemon/naemon-*/lib` && ln -s $$lib lib
	$(MAKE) -C $(DIR) all

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/naemon
	install -m 755 $(DIR)/src/.libs/livestatus.so $(DESTDIR)$(OMD_ROOT)/lib/naemon/livestatus.o.dbg
	install -sm 755 $(DIR)/src/.libs/livestatus.so $(DESTDIR)$(OMD_ROOT)/lib/naemon/livestatus.o
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(DIR)/src/unixcat $(DESTDIR)$(OMD_ROOT)/bin/unixcat
	install -m 755 lq $(DESTDIR)$(OMD_ROOT)/bin
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/python
	install -m 644 livestatus.py $(DESTDIR)$(OMD_ROOT)/lib/python

skel:

clean:
	rm -rf $(DIR)

upstream:
	rm -f *.gz
	wget https://github.com/naemon/naemon-livestatus/tarball/master -O tmp.tar.gz
	tar zxf tmp.tar.gz
	mv naemon-naemon-livestatus-??????? naemon-livestatus-master
	#set -e ; for p in patches/*.patch ; do \
	#    echo "applying $$p..." ; \
	#    ( cd naemon-livestatus-master && patch -p1 -b ) < $$p ; \
	#done
	cd naemon-livestatus-master && touch .naemon.official && autoreconf -i && ./configure && make dist && mv *.gz ..
	rm -rf tmp.tar.gz naemon-livestatus-master
	tar zxf naemon-livestatus-*.tar.gz
	rm naemon-livestatus-*.tar.gz
	mv naemon-livestatus-* naemon-livestatus-master
	tar cfz naemon-livestatus-master.tar.gz naemon-livestatus-master
	rm -rf naemon-livestatus-master
