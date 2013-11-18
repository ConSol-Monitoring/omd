include ../../Makefile.omd

NAME     = check_webinject
VERSION  = 1.86
DIR      = Webinject-$(VERSION)

.PHONY: skel

build:
	tar xzf $(DIR).tar.gz
	export PERL5LIB=$(P5TMPDIST)/dest/lib/perl5; \
	    cd $(DIR) && echo "" | $(PERL) Makefile.PL
	cd $(DIR) && $(MAKE) check_webinject

install:
	[ -d $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins ] || mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins
	install -m 755 $(DIR)/check_webinject $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins/

skel:

clean:
	rm -rf $(DIR)
