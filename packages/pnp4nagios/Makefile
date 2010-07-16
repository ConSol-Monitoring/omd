include ../../Makefile.omd

NAME = pnp4nagios
VERSION = 0.6.4
DIR = $(NAME)-$(VERSION)

# Configure options for Nagios. Since we want to compile
# as non-root, we use our own user and group for compiling.
# All files will be packaged as user 'root' later anyway.
CONFIGUREOPTS = \
    --prefix=$(OMD_ROOT) \
    --sysconfdir=$(OMD_ROOT)/etc/pnp4nagios \
    --libexecdir=$(OMD_ROOT)/lib/pnp4nagios \
    --docdir=$(OMD_ROOT)/share/doc/pnp4nagios \
    --datarootdir=$(OMD_ROOT)/share/pnp4nagios/htdocs \
	--with-perfdata-dir=$(OMD_ROOT)/var/pnp4nagios/perfdata \
	--with-perfdata-spool-dir=$(OMD_ROOT)/tmp/pnp4nagios/spool \
    --with-nagios-user=$$(id -un) \
    --with-nagios-group=$$(id -gn) \
    --with-rrdtool=/bin/true \
    --with-base-url='/\#\#\#SITE\#\#\#/pnp4nagios'

build:
	tar xzf $(DIR).tar.gz
	cd $(DIR) ; ./configure $(CONFIGUREOPTS)
	$(MAKE) -C $(DIR) all

install:
	mkdir -p $(DESTDIR)$(APACHE_CONF_DIR)
	$(MAKE) DESTDIR=$(DESTDIR) -C $(DIR) install
	# Remove installer 
	rm $(DESTDIR)$(OMD_ROOT)/share/pnp4nagios/htdocs/install.php

	# Move default config files to skel
	sed -i -e 's+/bin/true+###ROOT###/bin/rrdtool+' $(DESTDIR)$(OMD_ROOT)/etc/pnp4nagios/config.php
	
	mkdir -p skel/etc/pnp4nagios
	mkdir -p skel/var/pnp4nagios/stats
	mkdir -p skel/var/pnp4nagios/perfdata
	mkdir -p skel/tmp/pnp4nagios/spool

	mv $(DESTDIR)$(OMD_ROOT)/etc/pnp4nagios/* skel/etc/pnp4nagios
	
	mkdir -p skel/etc/init.d
	install -m 755 $(DIR)/scripts/rc.npcd skel/etc/init.d/npcd

skel:

clean:
	rm -rf $(DIR)
