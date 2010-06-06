include ../../Makefile.omd

NAME = pnp4nagios
VERSION = 0.6.3
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
    --with-nagios-user=$$(id -un) \
    --with-nagios-group=$$(id -gn) \
    --with-rrdtool=/bin/true 

build:
	tar xzf $(DIR).tar.gz
	cd $(DIR) ; ./configure $(CONFIGUREOPTS)
	$(MAKE) -C $(DIR) all

install:
	mkdir -p $(DESTDIR)/etc/apache2/conf.d
	$(MAKE) DESTDIR=$(DESTDIR) -C $(DIR) install install-html
	# Replace hard coded config with redirection to site specific version
	rm $(DESTDIR)$(OMD_ROOT)/share/pnp4nagios/htdocs/install.php
	install -m 644 config.php $(DESTDIR)$(OMD_ROOT)/share/pnp4nagios/htdocs/application/config/config.php
	# Remove log dir in read-only area. We log below @SITE@/var/log
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/pnp4nagios/htdocs/application/logs

skel:

clean:
	rm -rf $(DIR)
