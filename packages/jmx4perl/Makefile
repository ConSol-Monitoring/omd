include ../../Makefile.omd

NAME     = jmx4perl
VERSION  = 0.73_1
DIR      = $(NAME)-$(VERSION)

build:
	tar xzf $(DIR).tar.gz
	export PERL5LIB=$$(pwd)/../perl-modules/dist/lib/perl5:$$(pwd)/../perl-modules/dist/lib/perl5/$(PERLARCH); cd $(DIR) ; $(PERL) Build.PL
	cd $(DIR) && ./Build

install:
	rm -rf $(DESTDIR)$(OMD_ROOT)/skel/etc/jm4perl
	cp -rp $(DIR)/config $(DESTDIR)$(OMD_ROOT)/skel/etc/jmx4perl

clean:
	rm -rf $(DIR)
