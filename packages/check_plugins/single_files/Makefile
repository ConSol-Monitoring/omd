include ../../../Makefile.omd

NAME = single_file_plugins

PLUGINS=$(shell ls -1d check_*)

.PHONY: skel

build:

install:
	set -e; for plugin in $(PLUGINS); do \
		echo "install: $$plugin..." ; \
		install -m 755 $$plugin $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins; \
	done; \
	unzip -j ../../python-modules/src/omdeventhandler-*.whl eventhandler/bin_folder/eventhandler; \
	install -m 755 eventhandler $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins; \
	unzip -j ../../python-modules/src/omdnotificationforwarder-*.whl notificationforwarder/bin_folder/notificationforwarder; \
	install -m 755 notificationforwarder $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins

skel:
	install -D -m 644 skel/etc/histou/templates/custom/check_meminfo.php.example $(SKEL)/etc/histou/templates/custom/check_meminfo.php.example

clean:
