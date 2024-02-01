include ../../../Makefile.omd

NAME     = check_webinject
VERSION  = 1.96
DIR      = Webinject-$(VERSION)

.PHONY: skel

build:
	tar ozxf $(DIR).tar.gz
	for p in patches/*.patch ; do \
	    echo "applying $$p..." ; \
	    ( cd $(DIR) ; patch -p1 ) < $$p || exit 1; \
	done
	export PERL5LIB=$(P5TMPDIST)/dest/lib/perl5:.:lib; \
	    cd $(DIR) && echo "" | $(PERL) Makefile.PL
	cd $(DIR) && $(MAKE) check_webinject

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins
	install -m 755 $(DIR)/check_webinject $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins/

skel:

clean:
	rm -rf $(DIR)
