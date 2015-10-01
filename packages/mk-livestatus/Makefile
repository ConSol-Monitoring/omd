include ../../Makefile.omd

NAME = mk-livestatus
VERSION = 1.2.6p12
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
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/python
	install -m 644 $(DIR)/api/python/livestatus.py $(DESTDIR)$(OMD_ROOT)/lib/python

skel:

clean:
	rm -rf mk-livestatus-*.*.*[0-9]

upstream:
	if [ ! -e mk-livestatus-$(VERSION).tar.gz ] ; then \
	  git rm mk-livestatus-*.tar.gz || true ; \
	  rm -f mk-livestatus-*.tar.gz ; \
	  wget http://mathias-kettner.de/download/mk-livestatus-$(VERSION).tar.gz ; \
	  git add mk-livestatus-$(VERSION).tar.gz ; \
	fi
