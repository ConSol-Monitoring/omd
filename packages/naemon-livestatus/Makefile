include ../../Makefile.omd

NAME    = naemon-livestatus
CHANGELOG = https://github.com/naemon/naemon-livestatus/releases
VERSION = 1.6.0
DIR     = $(NAME)-$(VERSION)
DEPENDS = naemon

CONFIGUREOPTS = \
    --libdir=$(OMD_ROOT)/lib \
    --prefix=$(OMD_ROOT)

CFLAGS += -g3
CFLAGS += -fsigned-char

build:
	tar xfJ naemon-livestatus-$(VERSION).tar.xz
	#set -e ; for p in patches/*.patch ; do \
	#    echo "applying $$p..." ; \
	#    ( cd $(DIR) ; patch -p1 -b ) < $$p ; \
	#done
	touch $(DIR)/.naemon.official
	cd $(DIR); \
		autoreconf -s; \
		automake --add-missing; \
		NAEMON_LIBS="$(shell PKG_CONFIG_PATH="`ls -d1 ../naemon/naemon-*/.`" pkg-config --libs naemon-uninstalled)" \
		NAEMON_CFLAGS="$(shell PKG_CONFIG_PATH="`ls -d1 ../naemon/naemon-*/.`" pkg-config --cflags naemon-uninstalled) $(CFLAGS)" \
		  ./configure $(CONFIGUREOPTS)
	rm -f $(DIR)/src/lib $(DIR)/src/naemon
	cd $(DIR)/src && src=`ls -d1 ../../../naemon/naemon-*/src/naemon` && ln -s $$src naemon
	cd $(DIR)/src && lib=`ls -d1 ../../../naemon/naemon-*/lib` && ln -s $$lib lib
	$(MAKE) -C $(DIR) all
	rm -rf dest
	mkdir -p dest
	cp $(DIR)/src/.libs/livestatus.so ./dest/livestatus.so.dbg
	install -m 755 $(DIR)/src/unixcat ./dest/unixcat
	rm -rf $(DIR)

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/naemon
	install  -m 755 ./dest/livestatus.so.dbg $(DESTDIR)$(OMD_ROOT)/lib/naemon/livestatus.o.dbg
	install -sm 755 ./dest/livestatus.so.dbg $(DESTDIR)$(OMD_ROOT)/lib/naemon/livestatus.o
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 ./dest/unixcat $(DESTDIR)$(OMD_ROOT)/bin/unixcat
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/python
	install -m 644 livestatus.py $(DESTDIR)$(OMD_ROOT)/lib/python

skel:

clean:
	rm -rf $(DIR)
	rm -rf ./dest

# update naemon-livestatus to master (HEAD) and repack as xz
upstream: clean
	rm -f naemon-livestatus-master.tar.xz
	wget https://github.com/naemon/naemon-livestatus/tarball/master -O tmp.tar.gz
	tar zxf tmp.tar.gz
	mv naemon-naemon-livestatus-??????? naemon-livestatus-master
	cd naemon-livestatus-master && touch .naemon.official && autoreconf -i && rm -rf autom4te.cache
	XZ_OPT=-8 tar cfJ naemon-livestatus-master.tar.xz naemon-livestatus-master
	git add naemon-livestatus-master.tar.xz
	rm -rf naemon-livestatus-master tmp.tar.gz

# update naemon-livestatus to a release tag, repack as xz and bump VERSION in this Makefile:
#   make upstream-release VERSION=1.5.2
upstream-release:
	@test -n "$(VERSION)" || { echo "usage: make upstream-release VERSION=x.y.z"; exit 1; }
	rm -f naemon-livestatus-$(VERSION).tar.xz
	wget "https://github.com/naemon/naemon-livestatus/archive/refs/tags/v$(VERSION).tar.gz" -O tmp.tar.gz
	tar zxf tmp.tar.gz
	cd $(DIR) && touch .naemon.official && autoreconf -i && rm -rf autom4te.cache
	XZ_OPT=-8 tar cfJ naemon-livestatus-$(VERSION).tar.xz $(DIR)
	sed -i "s/^VERSION = .*/VERSION = $(VERSION)/" Makefile
	git add Makefile naemon-livestatus-$(VERSION).tar.xz
	rm -rf $(DIR) tmp.tar.gz
