include Makefile.omd

DESTDIR=$(shell pwd)/destdir
.PHONY: install-global
# You can select a subset of the packages by overriding this
# variale, e.g. make PACKAGES='nagios rrdtool' pack
PACKAGES = *

omd: build

build:
	@set -e ; cd packages ; for p in $(PACKAGES) ; do \
	    $(MAKE) -C $$p build ; \
        done

pack:
	rm -rf $(DESTDIR)
	@set -e ; cd packages ; for p in $(PACKAGES) ; do \
            $(MAKE) -C $$p DESTDIR=$(DESTDIR) install ; \
        done
	# Repair packages that install with silly modes (such as Nagios)
	chmod -R o+Xr $(DESTDIR)$(OMD_ROOT)
	$(MAKE) install-global
	# Install skeleton files (subdirs skel/ in packages' directories)
	mkdir -p $(DESTDIR)$(OMD_ROOT)/skel
	@set -e ; cd packages ; for p in $(PACKAGES) ; do \
            if [ -d "$$p/skel" ] ; then  \
              tar cf - -C $$p/skel --exclude="*~" --exclude=".gitignore" . | tar xvf - -C $(DESTDIR)$(OMD_ROOT)/skel ; \
            fi ;\
            $(MAKE) SKEL=$(DESTDIR)$(OMD_ROOT)/skel -C $$p skel ;\
        done
	tar czf omd-$(OMD_VERSION).tar.gz --owner=root --group=root -C $(DESTDIR) .

clean:
	rm -rf $(DESTDIR)
	@for p in packages/* ; do \
            $(MAKE) -C $$p clean ; \
        done

install-global:
	mkdir -p $(DESTDIR)/usr/bin
	install -m 755 bin/omd $(DESTDIR)/usr/bin
	mkdir -p $(DESTDIR)/omd/sites
	mkdir -p $(DESTDIR)/omd/apache
	# FIXME: Make this work on RedHat as well
	mkdir -p $(DESTDIR)/etc/apache2/conf.d
	install -m 644 apache.conf $(DESTDIR)/etc/apache2/conf.d/omd.conf
	mkdir -p $(DESTDIR)/etc/init.d
	install -m 755 omd.init $(DESTDIR)/etc/init.d/omd
	mkdir -p $(DESTDIR)/etc/bash_completion.d
	install -m 644 .omd_bash_completion $(DESTDIR)/etc/bash_completion.d/omd
