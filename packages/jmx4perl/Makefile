include ../../Makefile.omd

NAME     = jmx4perl
VERSION  = 1.11
JOLOKIA_VERSION = 1.2.3
DIR      = $(NAME)-$(VERSION)

.PHONY: skel

build:
	tar xzf $(DIR).tar.gz
#	for p in patches/*.patch ; do \
#	    echo "applying $$p..." ; \
#	    ( cd $(DIR) ; patch -p1 -b ) < $$p ; \
#	done
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
# Jolokia Agents
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/jmx4perl
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/jmx4perl/jolokia-$(JOLOKIA_VERSION)
	rsync -a jolokia-agents/$(JOLOKIA_VERSION)/ $(DESTDIR)$(OMD_ROOT)/share/jmx4perl/jolokia-$(JOLOKIA_VERSION)/
	chmod 644 $(DESTDIR)$(OMD_ROOT)/share/jmx4perl/jolokia-$(JOLOKIA_VERSION)/*

skel:
	rsync -a $(DIR)/config $(SKEL)/etc/jmx4perl/
	find $(SKEL)/etc/jmx4perl/ -type f -exec chmod 644 {} \;

clean:
	rm -rf $(DIR)
