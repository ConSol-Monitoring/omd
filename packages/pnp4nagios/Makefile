include ../../Makefile.omd

.PHONY: skel

NAME = pnp4nagios
VERSION = 0.6.42
DIR = $(NAME)-$(VERSION)
# Unset CONFIG_SITE
CONFIG_SITE = ''
DEPENDS = rrdtool

# Configure options for PNP4Nagios. Since we want to compile
# as non-root, we use our own user and group for compiling.
# All files will be packaged as user 'root' later anyway.
CONFIGUREOPTS = \
    --prefix=$(OMD_ROOT) \
    --libdir=$(OMD_ROOT)/lib \
    --sysconfdir=$(OMD_ROOT)/etc/pnp4nagios \
    --libexecdir=$(OMD_ROOT)/lib/pnp4nagios \
    --docdir=$(OMD_ROOT)/share/doc/pnp4nagios \
    --datarootdir=$(OMD_ROOT)/share/pnp4nagios/htdocs \
    --localstatedir=$(OMD_ROOT)/var/pnp4nagios \
    --with-perfdata-dir=$(OMD_ROOT)/var/pnp4nagios/perfdata \
    --with-perfdata-spool-dir=$(OMD_ROOT)/tmp/pnp4nagios/spool \
    --with-perfdata-logfile=$(OMD_ROOT)/var/pnp4nagios/log/perfdata.log \
    --with-nagios-user=$$(id -un) \
    --with-nagios-group=$$(id -gn) \
    --with-rrdtool=/bin/true \
    --with-perl_lib_path=$(OMD_ROOT)/lib/perl5/lib/perl5 \
    --with-base-url='/\#\#\#SITE\#\#\#/pnp4nagios'

RUN_AUTOMAKE=0
ifeq ($(shell uname -m),aarch64)
RUN_AUTOMAKE=1
endif

build:
	tar xzf $(DIR).tar.gz
	#for p in patches/*.patch ; do \
	#	echo "applying $$p..." ; \
	#	( cd $(DIR) ; patch -p1 ) < $$p ; \
    #   done
	-if [ "x$(RUN_AUTOMAKE)" = "x1" ]; then cd $(DIR) && automake -af; fi
	cd $(DIR) && ./configure $(CONFIGUREOPTS)
	$(MAKE) -C $(DIR) all
	rm -f $(DIR)/share/pnp/documents/de_DE/dwnld.html
	cp $(DIR)/share/pnp/documents/en_US/dwnld.html $(DIR)/share/pnp/documents/de_DE/dwnld.html

install:
	mkdir -p $(DESTDIR)$(APACHE_CONF_DIR)
	$(MAKE) DESTDIR=$(DESTDIR) -C $(DIR) install
	# Remove installer 
	rm $(DESTDIR)$(OMD_ROOT)/share/pnp4nagios/htdocs/install.php
	rm -rf $(DESTDIR)$(OMD_ROOT)/etc/pnp4nagios
	rm -rf $(DESTDIR)$(OMD_ROOT)/var/pnp4nagios
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/doc/pnp4nagios
	install -m 644 $(DIR)/README $(DESTDIR)$(OMD_ROOT)/share/doc/pnp4nagios
	install -m 644 $(DIR)/COPYING $(DESTDIR)$(OMD_ROOT)/share/doc/pnp4nagios
	install -m 644 $(DIR)/AUTHORS $(DESTDIR)$(OMD_ROOT)/share/doc/pnp4nagios
	install -m 644 $(DIR)/THANKS $(DESTDIR)$(OMD_ROOT)/share/doc/pnp4nagios
	
	# Move default config files to skel
	mkdir -p skel/etc/pnp4nagios
	mkdir -p skel/var/pnp4nagios/stats
	mkdir -p skel/var/pnp4nagios/perfdata
	mkdir -p skel/var/pnp4nagios/log
	mkdir -p skel/var/pnp4nagios/spool
	mkdir -p skel/tmp/pnp4nagios/run
	
	# override custom template
	install -m 644 check_gearman.php $(DESTDIR)$(OMD_ROOT)/share/pnp4nagios/htdocs/templates.dist/check_gearman.php

clean:
	rm -rf $(DIR)

upstream: package

package:
	rm -f $(DIR).tar.gz
	wget "https://github.com/ConSol/pnp/archive/refs/heads/master.tar.gz"
	tar zxf master.tar.gz
	rm -f master.tar.gz
	mv pnp-*/ $(DIR)
	tar cf $(DIR).tar $(DIR)
	gzip -9 $(DIR).tar
	rm -rf $(DIR)
