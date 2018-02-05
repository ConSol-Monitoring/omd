include ../../../Makefile.omd

NAME     = check_apache_serverstatus

.PHONY: skel

build:
	for p in patches/*.patch ; do \
	    echo "applying $$p..." ; \
	    ( patch -p1 ) < $$p || exit 1; \
	done

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins
	install -m 755 $(DIR)/check_apache_serverstatus.pl $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins/
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/pnp4nagios/htdocs/templates.dist
	install -m 644 $(DIR)/check_apache_serverstatus.php $(DESTDIR)$(OMD_ROOT)/share/pnp4nagios/htdocs/templates.dist

skel:

clean:

upstream:
	wget "https://raw.githubusercontent.com/SteScho/apache_serverstatus/master/check_apache_serverstatus.pl" -O check_apache_serverstatus.pl
	wget "https://raw.githubusercontent.com/SteScho/apache_serverstatus/master/check_apache_serverstatus.php" -O check_apache_serverstatus.php
