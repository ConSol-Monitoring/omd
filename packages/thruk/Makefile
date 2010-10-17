include ../../Makefile.omd

NAME     = Thruk
VERSION  = 0.72
DIR      = $(NAME)-$(VERSION)
PERLARCH = $(shell $(PERL) -e 'use Config; print $$Config{archname}')

build:
	tar xzf $(DIR).tar.gz
	for p in patches/*.patch ; do \
	    echo "applying $$p..." ; \
	    ( cd $(DIR) ; patch -p1 -b ) < $$p ; \
	done
	export PERL5LIB=$$(pwd)/../perl-modules/dist/lib/perl5:$$(pwd)/../perl-modules/dist/lib/perl5/$(PERLARCH); cd $(DIR) ; echo "" | $(PERL) Makefile.PL
	cd $(DIR) && make clean
	mkdir -p $(DIR)/root/thruk/plugins
	rm -f $(DIR)/root/thruk/plugins/statusmap
	cd $(DIR)/root/thruk/plugins && ln -s ../../../plugins/plugins-enabled/statusmap/root statusmap
	# logfile has to be group writeable for shared apache
	mkdir -p skel/var/log
	touch skel/var/log/thruk.log
	chmod 664 skel/var/log/thruk.log


install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/thruk
	cp -rp $(DIR) $(DESTDIR)$(OMD_ROOT)/share/thruk
	mkdir -p $(DESTDIR)$(OMD_ROOT)/skel/etc/thruk
	cp $(DIR)/thruk.conf $(DESTDIR)$(OMD_ROOT)/skel/etc/thruk/thruk.conf
	cp $(DIR)/menu.conf $(DESTDIR)$(OMD_ROOT)/skel/etc/thruk/menu.conf

skel:

clean:
	rm -rf $(DIR)
