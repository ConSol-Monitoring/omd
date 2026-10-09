include ../../Makefile.omd

NAME     = jmx4perl
VERSION  = 1.13
DIR      = $(NAME)-$(VERSION)

.PHONY: skel

build:
	tar xzf $(DIR).tar.gz
	export PERL5LIB=$(P5TMPDIST)/dest/lib/perl5; \
	    cd $(DIR) && $(PERL) Build.PL < /dev/null >build.log 2>&1
	cd $(DIR) && ./Build

install:
	install -m 0755 $(DIR)/blib/script/jmx4perl $(DESTDIR)$(OMD_ROOT)/bin/jmx4perl
	install -m 0755 $(DIR)/blib/script/j4psh $(DESTDIR)$(OMD_ROOT)/bin/j4psh
	install -m 0755 $(DIR)/blib/script/jolokia $(DESTDIR)$(OMD_ROOT)/bin/jolokia
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins
	install -m 0755 $(DIR)/blib/script/check_jmx4perl $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins/check_jmx4perl
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/perl5/lib/perl5
	rsync -a $(DIR)/blib/lib/ $(DESTDIR)$(OMD_ROOT)/lib/perl5/lib/perl5
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/man/man1
	rsync -a $(DIR)/blib/bindoc/ $(DESTDIR)$(OMD_ROOT)/share/man/man1
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/doc/jmx4perl
	install -m 644 README $(DESTDIR)$(OMD_ROOT)/share/doc/jmx4perl

skel:
	rsync -a $(DIR)/config $(SKEL)/etc/jmx4perl/
	find $(SKEL)/etc/jmx4perl/ -type f -exec chmod 644 {} \;

clean:
	rm -rf $(DIR)
