include ../../Makefile.omd

NAME     = gearmand
VERSION  = 0.14
DIR      = gearmand-$(VERSION)

.PHONY: skel

build:
	test -f gearmand-${VERSION}.tar.gz || wget "http://launchpad.net/gearmand/trunk/0.14/+download/gearmand-0.14.tar.gz"
	tar xzf gearmand-$(VERSION).tar.gz
	cd $(DIR) && ./configure --prefix=$(OMD_ROOT)
	cd $(DIR) && $(MAKE)

install:
	$(MAKE) DESTDIR=$(DESTDIR) -C $(DIR) install

skel:

clean:
	rm -rf $(DIR)
