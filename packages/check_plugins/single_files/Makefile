include ../../../Makefile.omd

NAME = single_file_plugins

PLUGINS=$(shell ls -1d check_* notificationforwarder)

.PHONY: skel

build:

install:
	set -e; for plugin in $(PLUGINS); do \
		echo "install: $$plugin..." ; \
		install -m 755 $$plugin $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins; \
	done

skel:
	install -D -m 644 skel/etc/histou/templates/custom/check_meminfo.php.example $(SKEL)/etc/histou/templates/custom/check_meminfo.php.example

clean:
