include ../../Makefile.omd

NAME = rrdtool
VERSION = 1.5.4
DIR = $(NAME)-$(VERSION)
PYTHON = $(shell realpath $$(pwd)/../python/tmp.python27/bin/python)

CONFIGUREOPTS = \
	--prefix=$(OMD_ROOT) \
	--disable-ruby \
	--disable-libwrap \
	--enable-perl-site-install \
	--disable-tcl \
	--disable-lua \
	--disable-rrdcgi \
	--with-perl-options="LIB=$(DESTDIR)$(OMD_ROOT)/lib/perl5/lib/perl5"

build: check-python
	if [ -d $(DIR) ]; then rm -rf $(DIR); fi
	tar xzf $(DIR).tar.gz
	for p in patches/*.diff ; do \
          echo "applying $$p..." ; \
          ( cd $(DIR) ; patch -p1 -b ) < $$p ; \
        done
	
	# set perl environment to match the other perl modules
	echo "install  --install_base  $(DESTDIR)$(OMD_ROOT)/lib/perl5" > .modulebuildrc
	export PERL5LIB=$(P5TMPDIST)/dest/lib/perl5; \
	  export PERL_MM_OPT=INSTALL_BASE=$(DESTDIR)$(OMD_ROOT)/lib/perl5; \
	  export MODULEBUILDRC=$$(pwd)/.modulebuildrc; \
	  export LDFLAGS="-lglib-2.0"; \
	  cd $(DIR) && \
	  ./configure $(CONFIGUREOPTS) && \
	  $(MAKE) all
	
	# Python binding
	cd $(DIR)/bindings/python && $(PYTHON) setup.py build

check-python:
	@if [ ! -d ../python/tmp.python27 ]; then \
	    echo "ERROR: You need to build the \"python\" package first" ; \
	    exit 1 ; \
	fi

install:
	export PERL5LIB=$(P5TMPDIST)/dest/lib/perl5; \
	$(MAKE) DESTDIR=$(DESTDIR) -C $(DIR) install
	
	# clean up perl man pages which end up in wrong location
	# clean up systemd init files
	if [ -n "$(DESTDIR)" ]; then \
	    rm -fr $(DESTDIR)/usr/local ; \
	    rm -fr $(DESTDIR)/lib ; \
	fi
	
	mkdir $(DESTDIR)$(OMD_ROOT)/share/doc/rrdtool || true
	install -m 644 $(DIR)/COPYRIGHT $(DESTDIR)$(OMD_ROOT)/share/doc/rrdtool
	install -m 644 $(DIR)/CONTRIBUTORS $(DESTDIR)$(OMD_ROOT)/share/doc/rrdtool
	
	# Python binding
	export PYTHONPATH=$$PYTHONPATH:$(DESTDIR)$(OMD_ROOT)/lib/python && \
	cd $(DIR)/bindings/python && \
	    $(PYTHON) setup.py install --home=$(DESTDIR)/$(OMD_ROOT) --prefix "" \
		--install-platlib=$(DESTDIR)$(OMD_ROOT)/lib/python \
		--install-purelib=$(DESTDIR)$(OMD_ROOT)/lib/python \
	
	if [ -n "$(DESTDIR)$(OMD_ROOT)" -a -d "$(DESTDIR)$(OMD_ROOT)/lib64" ] ; then \
	    rsync -avh $(DESTDIR)$(OMD_ROOT)/lib64/* $(DESTDIR)$(OMD_ROOT)/lib/ ; \
	    rm -rf $(DESTDIR)$(OMD_ROOT)/lib64 ; \
	fi

skel:

clean:
	rm -rf $(DIR)
	rm -rf .modulebuildrc
