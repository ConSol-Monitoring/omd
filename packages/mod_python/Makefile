include ../../Makefile.omd

NAME = mod_python
VERSION = 3.3.1
DIR = $(NAME)-$(VERSION)

CONFIGUREOPTS = \
    --prefix=$(OMD_ROOT)

build:
	tar xzf $(DIR).tar.gz
	set -e ; for p in patches/*.dif ; do \
	    echo "applying $$p..." ; \
	    ( cd $(DIR) ; patch -p1 -b ) < $$p ; \
	done
	cd $(DIR) ; ./configure $(CONFIGUREOPTS) 
	$(MAKE) -C $(DIR) all

install:
	# Use 'make install' of mod_python into a temporary file.
	# mod_python does not honor --prefix, so we move the stuff over...
	make DESTDIR=$$(pwd)/tmp.root -C $(DIR) install
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/apache/modules
	install -m 644 tmp.root/usr/lib/*/modules/mod_python.so $(DESTDIR)$(OMD_ROOT)/lib/apache/modules
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/python/mod_python
	install tmp.root/usr/local/lib/*/dist-packages/mod_python/* $(DESTDIR)$(OMD_ROOT)/lib/python/mod_python
	install -m 644 tmp.root/usr/local/lib/python2.7/dist-packages/mod_python-3.3.1.egg-info $(DESTDIR)$(OMD_ROOT)/lib/python
	rm -rf tmp.root

skel:

clean:
	rm -rf $(NAME)-*.*.[0-9] tmp.root

