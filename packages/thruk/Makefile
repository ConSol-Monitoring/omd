include ../../Makefile.omd

NAME     = Thruk
VERSION  = 1.0.6
DIR      = $(NAME)-$(VERSION)
PERLARCH = $(shell $(PERL) -e 'use Config; print $$Config{archname}')

.PHONY: skel

build:
	tar xzf $(DIR)-src.tar.gz
	for p in patches/*.patch ; do \
	    echo "applying $$p..." ; \
	    ( cd $(DIR) ; patch -p1 -b ) < $$p ; \
	done
	export PERL5LIB=$$(pwd)/../perl-modules/dist/lib/perl5:$$(pwd)/../perl-modules/dist/lib/perl5/$(PERLARCH); cd $(DIR) ; echo "" | $(PERL) Makefile.PL
	cd $(DIR) && make distclean


install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/thruk
	cp -rp $(DIR) $(DESTDIR)$(OMD_ROOT)/share/thruk
	mkdir -p $(DESTDIR)$(OMD_ROOT)/skel/etc/thruk
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/thruk/plugins/plugins-enabled
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/thruk/t

skel:
	# logfile has to be group writeable for shared apache
	mkdir -p $(SKEL)/var/log
	touch $(SKEL)/var/log/thruk.log
	mkdir -p $(SKEL)/etc/thruk/plugins/plugins-enabled
	mkdir -p $(SKEL)/etc/thruk/plugins/plugins-available
	# set links for available plugins
	for link in `ls -1 $(DIR)/plugins/plugins-available/`; do cd $(SKEL)/etc/thruk/plugins/plugins-available && ln -sfn $$link $$link; done
	# set links for enabled plugins
	for link in `ls -1 $(DIR)/plugins/plugins-enabled/`; do cd $(SKEL)/etc/thruk/plugins/plugins-enabled && ln -sfn ../plugins-available/$$link $$link; done

clean:
	rm -rf $(DIR)
