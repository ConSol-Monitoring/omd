include Makefile.omd

DESTDIR=$$(pwd)/destdir
.PHONY: install-global

omd: build

build:
	@set -e ; for p in packages/* ; do \
	    $(MAKE) -C $$p build ; \
        done

pack:
	rm -rf $(DESTDIR)
	@set -e ; for p in packages/* ; do \
            $(MAKE) -C $$p DESTDIR=$(DESTDIR) install ; \
        done
	# Repair packages that install with silly modes (such as Nagios)
	chmod -R o+Xr $(DESTDIR)$(OMD_ROOT)
	$(MAKE) install-global
	# Install skeleton files (subdirs skel/ in packages' directories)
	mkdir -p $(DESTDIR)$(OMD_ROOT)/skel
	@set -e ; for p in packages/* ; do \
            if [ -d "$$p/skel" ] ; then  \
              tar cf - -C $$p/skel --exclude="*~" . | tar xvf - -C $(DESTDIR)$(OMD_ROOT)/skel ; \
            fi ;\
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
	install -m 755 omd.init $(DESTDIR)/etc/init.d
