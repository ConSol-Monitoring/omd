include ../../Makefile.omd

NAME = check_plugins

PLUGINS=$(shell ls -1d check_*)

build:
	set -e; for plugin in $(PLUGINS); do \
		echo "build: $$plugin..." ; \
		$(MAKE) -C $$plugin build; \
	done

install:
	set -e; for plugin in $(PLUGINS); do \
		echo "build: $$plugin..." ; \
		$(MAKE) DESTDIR=$(DESTDIR) -C $$plugin install; \
	done

skel:
	set -e; for plugin in $(PLUGINS); do \
		echo "build: $$plugin..." ; \
		$(MAKE) DESTDIR=$(DESTDIR) SKEL=$(SKEL) -C $$plugin skel; \
	done

clean:
	set -e; for plugin in $(PLUGINS); do \
		echo "build: $$plugin..." ; \
		$(MAKE) -C $$plugin clean; \
	done
