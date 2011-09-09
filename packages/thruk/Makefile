include ../../Makefile.omd

NAME     = Thruk
VERSION  = 1.1.0
DIR      = $(NAME)-$(VERSION)
PERLARCH = $(shell $(PERL) -e 'use Config; print $$Config{archname}')

.PHONY: skel

build:
	rm -rf $(DIR)
	tar xzf $(DIR)-src.tar.gz
	for p in patches/*.patch ; do \
	    echo "applying $$p..." ; \
	    ( cd $(DIR) ; patch -p1 -b ) < $$p ; \
	done
	export PERL5LIB=$$(pwd)/../perl-modules/dist/lib/perl5:$$(pwd)/../perl-modules/dist/lib/perl5/$(PERLARCH); cd $(DIR) ; echo "" | $(PERL) Makefile.PL


install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/thruk
	cp -rp $(DIR) $(DESTDIR)$(OMD_ROOT)/share/thruk
	mkdir -p $(DESTDIR)$(OMD_ROOT)/skel/etc/thruk
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/thruk/plugins-enabled
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/thruk/themes-enabled
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/thruk/t

skel:
	# logfile has to be group writeable for shared apache
	mkdir -p $(SKEL)/var/log
	touch $(SKEL)/var/log/thruk.log
	mkdir -p $(SKEL)/etc/thruk/plugins-enabled
	# set links for enabled plugins
	for link in `ls -1 $(DIR)/plugins/plugins-enabled/`; do cd $(SKEL)/etc/thruk/plugins-enabled && ln -sfn ../../../share/thruk/plugins/plugins-available/$$link $$link; done
	# set links for enabled themes
	mkdir -p $(SKEL)/etc/thruk/themes-enabled
	for link in `ls -1 $(DIR)/themes/themes-enabled/`; do cd $(SKEL)/etc/thruk/themes-enabled && ln -sfn ../../../share/thruk/themes/themes-available/$$link $$link; done

clean:
	rm -rf $(DIR)
