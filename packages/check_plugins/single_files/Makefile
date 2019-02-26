include ../../../Makefile.omd

NAME = single_file_plugins

PLUGINS=$(shell ls -1d check_*)

build:

install:
	set -e; for plugin in $(PLUGINS); do \
		echo "install: $$plugin..." ; \
		install -m 755 $$plugin $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins; \
	done

skel:

clean:
