include ../../Makefile.omd

NAME = mk-livestatus
VERSION = 1.2.8p20
DIR = $(NAME)-$(VERSION)

unexport MAKEFLAGS

CONFIGUREOPTS = \
    --prefix=$(OMD_ROOT)

TMPGCC = $(shell pwd)/../gcc/tmp_gcc
export PATH := $(TMPGCC)/bin/:$(PATH)
export LD_LIBRARY_PATH := $(TMPGCC)/lib64:$(LD_LIBRARY_PATH)
ifneq (,$(findstring SLES 11SP4,$(DISTRO_INFO)))
export CC := gcc-4.8
export CXX := g++-4.8
else ifneq (,$(findstring SLES 11SP2,$(DISTRO_INFO)))
export CC := gcc
export CXX := g++
else ifneq (,$(findstring SLES 11SP,$(DISTRO_INFO)))
export CC := gcc-4.7
export CXX := g++-4.7
endif


build:
	tar xzf $(DIR).tar.gz
	cd $(DIR) ; ./configure $(CONFIGUREOPTS)
	$(MAKE) -C $(DIR) all

install:
	$(MAKE) DESTDIR=$(DESTDIR) -C $(DIR) install
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 lq $(DESTDIR)$(OMD_ROOT)/bin
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/python
	install -m 644 livestatus.py $(DESTDIR)$(OMD_ROOT)/lib/python

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

