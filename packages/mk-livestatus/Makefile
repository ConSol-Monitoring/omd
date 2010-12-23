include ../../Makefile.omd

NAME = mk-livestatus
VERSION = 1.1.9i3
DIR = $(NAME)-$(VERSION)

CONFIGUREOPTS = \
    --prefix=$(OMD_ROOT)

build:
	tar xzf $(DIR).tar.gz
	cd $(DIR) ; ./configure $(CONFIGUREOPTS)
	$(MAKE) -C $(DIR) all

install:
	$(MAKE) DESTDIR=$(DESTDIR) -C $(DIR) install
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 lq $(DESTDIR)$(OMD_ROOT)/bin

skel:

clean:
	rm -rf mk-livestatus-*.*.*[0-9]
