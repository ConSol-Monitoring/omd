include ../../Makefile.omd

NAME    = perl-modules
VERSION = $(OMD_VERSION)
PERL    = /usr/bin/perl
LLSRC   = $(shell basename src/local-lib-*.gz | sed s/\.tar\.gz// )

MODULES = YAML-0.72.tar.gz \
          Scalar-List-Utils-1.23.tar.gz \
          common-sense-3.0.tar.gz \
          JSON-XS-2.3.tar.gz \
          Monitoring-Livestatus-0.60.tar.gz


build: clean locallib
	# now install all other modules
	cd src; \
	for tarball in $(MODULES); do \
	    ../build_module.sh $(PERL) $$tarball; \
	done

install:
	if [ -z $(DESTDIR) ]; then echo "cannot install without DESTDIR set!"; exit 1; fi
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib
	mv dist $(DESTDIR)$(OMD_ROOT)/lib/perl5

skel:

clean:
	rm -rf src/$(LLSRC)
	rm -rf dist

locallib:
	mkdir dist
	cd src; tar zxf $(LLSRC).tar.gz
	cd src/$(LLSRC); echo "" | $(PERL) Makefile.PL --bootstrap=../../dist
	cd src/$(LLSRC); $(MAKE) install
