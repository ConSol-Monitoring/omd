include ../../Makefile.omd

NAME = naemon-livestatus
VERSION = 1.0.8
DIR = $(NAME)-$(VERSION)

CONFIGUREOPTS = \
    --prefix=$(OMD_ROOT)

build:
	tar xzf $(NAME)-$(VERSION).tar.gz
	set -e ; for p in patches/*.patch ; do \
	    echo "applying $$p..." ; \
	    ( cd $(DIR) ; patch -p1 -b ) < $$p ; \
	done
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
	cp $(DIR)/src/.libs/livestatus.so $(DESTDIR)$(OMD_ROOT)/lib/naemon/livestatus.o

skel:
	mkdir -p $(SKEL)/etc/naemon
	sed -e 's/mk-livestatus\/livestatus.o/naemon\/livestatus.o/g' $(SKEL)/etc/mk-livestatus/nagios.cfg > $(SKEL)/etc/naemon/livestatus.cfg

clean:
	rm -rf $(DIR)

upstream:
	rm -f livestatus.tar.gz
	wget https://github.com/naemon/naemon-livestatus/tarball/master -O tmp.tar.gz
	tar zxf tmp.tar.gz
	mv naemon-naemon-livestatus-??????? naemon-livestatus-master
	cd naemon-livestatus-master && autoreconf -i
	tar cfz naemon-livestatus-master.tar.gz naemon-livestatus-master
	rm -rf tmp.tar.gz naemon-livestatus-master
	git add naemon-livestatus-master.tar.gz
