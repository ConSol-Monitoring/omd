include ../../Makefile.omd

NAME     = check_webinject
VERSION  = 1.55
DIR      = Webinject-$(VERSION)
PERLARCH = $(shell $(PERL) -e 'use Config; print $$Config{archname}')

.PHONY: skel

build:
	tar xzf $(DIR).tar.gz
	export PERL5LIB=$$(pwd)/../perl-modules/dist/lib/perl5:$$(pwd)/../perl-modules/dist/lib/perl5/$(PERLARCH); cd $(DIR) && echo "" | $(PERL) Makefile.PL
	cd $(DIR) && $(MAKE) check_webinject

install:
	[ -d $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins ] || mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins
	install -m 755 $(DIR)/check_webinject $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins/

skel:

clean:
	rm -rf $(DIR)
