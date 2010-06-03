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
	$(MAKE) install-global
	tar czf --owner=root --group=root omd-$(OMD_VERSION).tar.gz -C $(DESTDIR) .

clean:
	rm -rf $(DESTDIR)
	@for p in packages/* ; do \
            $(MAKE) -C $$p clean ; \
        done

install-global:
	mkdir -p $(DESTDIR)/usr/bin
	install -m 755 bin/omd $(DESTDIR)/usr/bin
	mkdir -p $(DESTDIR)/omd/sites
