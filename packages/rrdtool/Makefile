include ../../Makefile.omd

NAME = rrdtool
VERSION = 1.9.0
DIR = $(NAME)-$(VERSION)

CONFIGUREOPTS = \
	--prefix=$(OMD_ROOT) \
	--libdir=$(OMD_ROOT)/lib \
	--disable-ruby \
	--disable-libwrap \
	--enable-perl-site-install \
	--disable-tcl \
	--disable-lua \
	--disable-rrdcgi \
	--with-perl-options="LIB=$(DESTDIR)$(OMD_ROOT)/lib/perl5/lib/perl5"

build:
	if [ -d $(DIR) ]; then rm -rf $(DIR); fi
	tar xzf $(DIR).tar.gz
	#
	# set perl environment to match the other perl modules
	echo "install  --install_base  $(DESTDIR)$(OMD_ROOT)/lib/perl5" > .modulebuildrc
	export PERL5LIB=$(P5TMPDIST)/dest/lib/perl5; \
	  export PERL_MM_OPT=INSTALL_BASE=$(DESTDIR)$(OMD_ROOT)/lib/perl5; \
	  export MODULEBUILDRC=$$(pwd)/.modulebuildrc; \
	  export LDFLAGS="-lglib-2.0"; \
	  export PYTHON=python3; \
	  cd $(DIR) && \
	  ./configure $(CONFIGUREOPTS) && \
	  $(MAKE) all
	
	# Python binding
	cd $(DIR)/bindings/python && python3 setup.py build
	
	rm -rf ./dest
	mkdir -p ./dest
	export PERL5LIB=$(P5TMPDIST)/dest/lib/perl5; \
	$(MAKE) DESTDIR=$(shell pwd)/dest -C $(DIR) install
	find ./dest/$(OMD_ROOT)/lib/perl5/ -type f -exec chmod u+rw  {} \; # strip fails otherwise
	find ./dest/$(OMD_ROOT)/lib/perl5/ -type d -exec chmod u+rwx {} \; # strip fails otherwise
	# clean up perl man pages which end up in wrong location
	rm -fr ./dest/usr/share/man
	rm -fr ./dest/usr/local
	# clean up systemd init files
	rm -fr ./dest/lib
	
	# Python binding
	cd $(DIR)/bindings/python && python3 setup.py install --root=$(shell pwd)/dest/$(OMD_ROOT) --home ""
	if [ -n "./dest/$(OMD_ROOT)" -a -d "./dest/$(OMD_ROOT)/lib64" ] ; then \
	    rsync -ah ./dest/$(OMD_ROOT)/lib64/* ./dest/$(OMD_ROOT)/lib/ ; \
	    rm -rf ./dest/$(OMD_ROOT)/lib64 ; \
	fi
	# Cleanup files below lib/python3*. The real stuff is in lib/python
	if ls ./dest/$(OMD_ROOT)/lib/python3* >/dev/null 2>&1; then \
	    rm -rf ./dest/$(OMD_ROOT)/lib/python3* ; \
	fi

install:
	rsync -a ./dest/$(OMD_ROOT)/. $(DESTDIR)/$(OMD_ROOT)/.

skel:

clean:
	rm -rf ./dest
	rm -rf $(DIR)
	rm -rf .modulebuildrc
