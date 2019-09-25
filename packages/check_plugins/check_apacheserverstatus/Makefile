include ../../../Makefile.omd

NAME     = check_apache_serverstatus

.PHONY: skel

build:
	mkdir -p build
	cp check_apache_serverstatus.pl build/check_apache_serverstatus.pl
	#for p in patches/*.patch ; do \
	#    echo "applying $$p..." ; \
	#    ( cd build && patch -p1 ) < $$p || exit 1; \
	#done

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins
	install -m 755 ./build/check_apache_serverstatus.pl $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins/
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/pnp4nagios/htdocs/templates.dist
	install -m 644 ./check_apache_serverstatus.php $(DESTDIR)$(OMD_ROOT)/share/pnp4nagios/htdocs/templates.dist
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/histou/templates/default/
	install -m 644 ./apache_status.simple $(DESTDIR)$(OMD_ROOT)/share/histou/templates/default/apache_status.simple


skel:

clean:
	rm -rf build

upstream:
	wget "https://raw.githubusercontent.com/SteScho/apache_serverstatus/master/check_apache_serverstatus.pl" -O check_apache_serverstatus.pl
	wget "https://raw.githubusercontent.com/SteScho/apache_serverstatus/master/check_apache_serverstatus.php" -O check_apache_serverstatus.php
