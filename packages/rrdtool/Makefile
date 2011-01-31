include ../../Makefile.omd

NAME = rrdtool
VERSION = 1.4.5
DIR = $(NAME)-$(VERSION)

CONFIGUREOPTS = \
    --prefix=$(OMD_ROOT) \
	--disable-ruby \
	--disable-python \
	--with-perl-options=""

build:
	tar xzf $(DIR).tar.gz
	# set perl environment to match the other perl modules
	echo "install  --install_base  $(DESTDIR)$(OMD_ROOT)/lib/perl5" > .modulebuildrc
	export PERL_MM_OPT=INSTALL_BASE=$(DESTDIR)$(OMD_ROOT)/lib/perl5; \
	export MODULEBUILDRC=$$(pwd)/.modulebuildrc; \
	cd $(DIR) && \
	./configure $(CONFIGUREOPTS) && \
	$(MAKE) all

install:
	$(MAKE) DESTDIR=$(DESTDIR) -C $(DIR) install
	
	mkdir $(DESTDIR)$(OMD_ROOT)/share/doc/rrdtool
	install -m 644 $(DIR)/README $(DESTDIR)$(OMD_ROOT)/share/doc/rrdtool
	install -m 644 $(DIR)/COPYING $(DESTDIR)$(OMD_ROOT)/share/doc/rrdtool
	install -m 644 $(DIR)/COPYRIGHT $(DESTDIR)$(OMD_ROOT)/share/doc/rrdtool
	install -m 644 $(DIR)/CONTRIBUTORS $(DESTDIR)$(OMD_ROOT)/share/doc/rrdtool

skel:

clean:
	rm -rf $(DIR)
	rm -rf .modulebuildrc
