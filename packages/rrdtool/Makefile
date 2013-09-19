include ../../Makefile.omd

NAME = rrdtool
VERSION = 1.4.8
DIR = $(NAME)-$(VERSION)

CONFIGUREOPTS = \
    --prefix=$(OMD_ROOT) \
	--disable-ruby \
	--disable-libwrap \
	--with-perl-options=""

build:
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
	cd $(DIR)/bindings/python && python setup.py build

install:
	export PERL5LIB=$(P5TMPDIST)/dest/lib/perl5; \
	$(MAKE) DESTDIR=$(DESTDIR) -C $(DIR) install
	
	mkdir $(DESTDIR)$(OMD_ROOT)/share/doc/rrdtool
	install -m 644 $(DIR)/README $(DESTDIR)$(OMD_ROOT)/share/doc/rrdtool
	install -m 644 $(DIR)/COPYING $(DESTDIR)$(OMD_ROOT)/share/doc/rrdtool
	install -m 644 $(DIR)/COPYRIGHT $(DESTDIR)$(OMD_ROOT)/share/doc/rrdtool
	install -m 644 $(DIR)/CONTRIBUTORS $(DESTDIR)$(OMD_ROOT)/share/doc/rrdtool

	# Python binding
	cd $(DIR)/bindings/python && python setup.py install --root=$(DESTDIR)/$(OMD_ROOT) --home ""

skel:

clean:
	rm -rf $(DIR)
	rm -rf .modulebuildrc
