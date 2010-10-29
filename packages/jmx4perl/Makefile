include ../../Makefile.omd

NAME     = jmx4perl
VERSION  = 0.73_1
DIR      = $(NAME)-$(VERSION)

.PHONY: skel

build:
	tar xzf $(DIR).tar.gz
	export PERL5LIB=$$(pwd)/../perl-modules/dist/lib/perl5:$$(pwd)/../perl-modules/dist/lib/perl5/$(PERLARCH); cd $(DIR) ; $(PERL) Build.PL
	cd $(DIR) && ./Build 

install:
	rm -rf $(DESTDIR)$(OMD_ROOT)/skel/etc/jmx4perl
	mkdir -p $(DESTDIR)$(OMD_ROOT)/skel/etc/jmx4perl
	cp -rp $(DIR)/config $(DESTDIR)$(OMD_ROOT)/skel/etc/jmx4perl/config
	cp -p $(DIR)/blib/script/{jmx4perl,j4psh} $(DESTDIR)$(OMD_ROOT)/bin/
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins
	cp -p $(DIR)/blib/script/check_jmx4perl $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins/
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/perl5/lib/perl5
	cp -rp $(DIR)/blib/lib/ $(DESTDIR)$(OMD_ROOT)/lib/perl5/lib/perl5

skel:

clean:
	rm -rf $(DIR)
