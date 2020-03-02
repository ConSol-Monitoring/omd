include ../../Makefile.omd

NAME    = check_plugins
PLUGINS = $(shell ls -1d check_*)

.PHONY: skel

build:
	set -e; for plugin in $(PLUGINS); do \
		echo "build: $$plugin..." ; \
		$(MAKE) -C $$plugin build; \
	done

install:
	set -e; for plugin in $(PLUGINS); do \
		echo "install: $$plugin..." ; \
		$(MAKE) DESTDIR=$(DESTDIR) -C $$plugin install; \
	done; \
	echo "install: simple plugins"; \
	$(MAKE) DESTDIR=$(DESTDIR) -C single_files install

skel:
	mkdir -p skel
	set -e; for plugin in $(PLUGINS); do \
		echo "skel: $$plugin..." ; \
		$(MAKE) DESTDIR=$(DESTDIR) SKEL=$(SKEL) -C $$plugin skel; \
		[ ! -d $$plugin/skel ] || rsync -a $$plugin/skel/. $(SKEL)/. ; \
	done
	$(MAKE) DESTDIR=$(DESTDIR) -C single_files skel

clean:
	set -e; for plugin in $(PLUGINS); do \
		echo "clean: $$plugin..." ; \
		$(MAKE) -C $$plugin clean; \
	done
