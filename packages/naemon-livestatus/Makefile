include ../../Makefile.omd

NAME = naemon-livestatus
VERSION = 1.0.2
DIR = $(NAME)-$(VERSION)

CONFIGUREOPTS = \
    --prefix=$(OMD_ROOT)

build:
	tar xzf $(NAME)-$(VERSION).tar.gz
	cd $(DIR) ; NAEMON_LIBS="-L$(shell pwd)/../naemon/naemon-*/src" NAEMON_CFLAGS="-I$(shell pwd)../naemon/naemon-*/src" ./configure $(CONFIGUREOPTS)
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
	rm -rf naemon-livestatus-master

upstream:
	rm -f livestatus.tar.gz
	wget https://github.com/naemon/naemon-livestatus/tarball/master -O tmp.tar.gz
	tar zxf tmp.tar.gz
	mv naemon-naemon-livestatus-??????? naemon-livestatus-master
	cd naemon-livestatus-master && autoreconf -i
	tar cfz naemon-livestatus-master.tar.gz naemon-livestatus-master
	rm -rf tmp.tar.gz naemon-livestatus-master
	git add naemon-livestatus-master.tar.gz
