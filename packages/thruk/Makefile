include ../../Makefile.omd

NAME = Thruk
VERSION = 0.72
DIR = $(NAME)-$(VERSION)

build:
	tar xzf $(DIR).tar.gz
	for p in patches/*.patch ; do \
	    echo "applying $$p..." ; \
	    ( cd $(DIR) ; patch -p1 -b ) < $$p ; \
	done
	eval $$($(PERL) -I../perl-modules/dist/lib/perl5 -Mlocal::lib=../perl-modules/dist); cd $(DIR) ; echo "" | $(PERL) Makefile.PL
	cd $(DIR) && make clean
	mkdir -p $(DIR)/root/thruk/plugins
	rm -f $(DIR)/root/thruk/plugins/statusmap
	cd $(DIR)/root/thruk/plugins && ln -s ../../../plugins/plugins-enabled/statusmap/root statusmap


install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/thruk
	cp -rp $(DIR) $(DESTDIR)$(OMD_ROOT)/share/thruk

skel:

clean:
	rm -rf $(DIR)
