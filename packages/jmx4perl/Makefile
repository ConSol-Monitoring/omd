include ../../Makefile.omd

NAME     = jmx4perl
VERSION  = 0.74
DIR      = $(NAME)-$(VERSION)

.PHONY: skel

build:
	tar xzf $(DIR).tar.gz
#	for p in patches/*.patch ; do \
#	    echo "applying $$p..." ; \
#	    ( cd $(DIR) ; patch -p1 -b ) < $$p ; \
#	done
	export PERL5LIB=$$(pwd)/../perl-modules/dist/lib/perl5:$$(pwd)/../perl-modules/dist/lib/perl5/$(PERLARCH); cd $(DIR) ; $(PERL) Build.PL
	cd $(DIR) && ./Build 

install:
	rm -rf $(DESTDIR)$(OMD_ROOT)/skel/etc/jmx4perl
	mkdir -p $(DESTDIR)$(OMD_ROOT)/skel/etc/jmx4perl
	rsync -a $(DIR)/config $(DESTDIR)$(OMD_ROOT)/skel/etc/jmx4perl/
	chmod 644 $(DESTDIR)$(OMD_ROOT)/skel/etc/jmx4perl/config/*.cfg
	cp -p $(DIR)/blib/script/jmx4perl $(DESTDIR)$(OMD_ROOT)/bin/
	cp -p $(DIR)/blib/script/j4psh $(DESTDIR)$(OMD_ROOT)/bin/
	[ -d $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins ] || mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins
	cp -p $(DIR)/blib/script/check_jmx4perl $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins/
	[ -d $(DESTDIR)$(OMD_ROOT)/lib/perl5/lib/perl5 ] || mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/perl5/lib/perl5
	rsync -a $(DIR)/blib/lib/ $(DESTDIR)$(OMD_ROOT)/lib/perl5/lib/perl5
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/man/man1
	rsync -a $(DIR)/blib/bindoc/ $(DESTDIR)$(OMD_ROOT)/share/man/man1
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/jmx4perl
	cp $(DIR)/agent/j4p.war $(DESTDIR)$(OMD_ROOT)/share/jmx4perl
	cp README.agent $(DESTDIR)$(OMD_ROOT)/share/jmx4perl/README

skel:

clean:
	rm -rf $(DIR)
