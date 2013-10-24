include ../../Makefile.omd

NAME = mod_python
VERSION = 3.3.1
DIR = $(NAME)-$(VERSION)

CONFIGUREOPTS = \
    --prefix=$(OMD_ROOT)

APACHE_VERSION      = $(shell $(APACHE_BIN) -v | awk '/version/ {print $$3}' | awk -F/ '{print $$2}')
APACHE_VERSION_MAIN = $(word 1, $(subst ., ,$(APACHE_VERSION)))
APACHE_VERSION_SUB  = $(word 2, $(subst ., ,$(APACHE_VERSION)))


build:
	tar xzf $(DIR).tar.gz
	set -e ; for p in patches/*.dif ; do \
	    echo "applying $$p..." ; \
	    ( cd $(DIR) ; patch -p1 -b ) < $$p ; \
	done
	# Apply special patch for apache >= 2.4
	if [ $(APACHE_VERSION_MAIN) -ge 2 -a $(APACHE_VERSION_SUB) -ge 4 ]; then \
	    echo "applying patches/0008-apache24.patch..." ; \
	    ( cd $(DIR) ; patch -p1 -b ) < patches/0008-apache24.patch ; \
	fi
	cd $(DIR) ; ./configure $(CONFIGUREOPTS) 
	echo '#define OMD_VERSION "$(OMD_VERSION)"' > $(DIR)/src/omd_version.h
	$(MAKE) -C $(DIR) all

install:
	# Use 'make install' of mod_python into a temporary file.
	# mod_python does not honor --prefix, so we move the stuff over...
	make DESTDIR=$$(pwd)/tmp.root -C $(DIR) install
	
	# Installation directories vary much
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/apache/modules
	MP=$$(find tmp.root -name mod_python.so) ; \
	install -m 644 $$MP $(DESTDIR)$(OMD_ROOT)/lib/apache/modules
	
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/python/mod_python
	PYDIR=$$(find tmp.root -name "*egg*" | sed 's@/mod_python.*@@') ; \
	if [ -z "$$PYDIR" ] ; then PYDIR=$$(find tmp.root/ -name __init__.py | sed 's@/mod_python/__init__.*@@') ; fi ; \
	install $$PYDIR/mod_python/* $(DESTDIR)$(OMD_ROOT)/lib/python/mod_python ; \
	if [ -e $$PYDIR/*egg* ] ; then install -m 644 $$PYDIR/*egg* $(DESTDIR)$(OMD_ROOT)/lib/python ; fi
	rm -rf tmp.root

skel:

clean:
	rm -rf $(NAME)-*.*.[0-9] tmp.root

