include ../../Makefile.omd

NAME     = Python
VERSION  = 2.7.11
DIR      = $(NAME)-$(VERSION)

.PHONY: skel

build:
	tar xzf $(DIR).tgz
	cd $(DIR) ; \
	./configure \
	    --prefix="" \
	    --enable-shared \
	    --enable-unicode=ucs4 \
	    LDFLAGS="-Wl,--rpath,$(OMD_ROOT)/lib" \
	; \
	$(MAKE) -j2
	
	# Install python files (needed by dependent packages like mod_python, python-modules, ...)
	# during compilation and install targets
	$(MAKE) -C $(DIR) DESTDIR=$(shell pwd)/tmp.python27 install

install:
	$(MAKE) -C $(DIR) DESTDIR=$(DESTDIR)$(OMD_ROOT) install
	
	# Cleanup some unused stuff
	rm $(DESTDIR)$(OMD_ROOT)/bin/idle
	rm $(DESTDIR)$(OMD_ROOT)/bin/smtpd.py
	
	# Fix python interpreter for kept scripts
	sed -i "1s|^#!.*python|#!$(OMD_ROOT)/bin/python|" \
	    $(DESTDIR)$(OMD_ROOT)/bin/pydoc \
	    $(DESTDIR)$(OMD_ROOT)/bin/python2.7-config \
	    $(DESTDIR)$(OMD_ROOT)/bin/2to3

skel:

clean:
	rm -rf $(DIR) tmp.python27

