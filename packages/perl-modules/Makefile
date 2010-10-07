include ../../Makefile.omd

NAME    = perl-modules
VERSION = $(OMD_VERSION)
PERL    = /usr/bin/perl
LLSRC   = $(shell basename src/local-lib-*.gz | sed s/\.tar\.gz// )

MODULES = YAML-0.72.tar.gz \
          YAML-Tiny-1.44.tar.gz \
          Scalar-List-Utils-1.23.tar.gz \
          common-sense-3.0.tar.gz \
          JSON-2.26.tar.gz \
          JSON-XS-2.3.tar.gz \
          Compress-Raw-Zlib-2.030.tar.gz \
          Sub-Uplevel-0.22.tar.gz \
          Variable-Magic-0.44.tar.gz \
          Path-Class-0.21.tar.gz \
          Config-General-2.49.tar.gz \
          File-Copy-Recursive-0.38.tar.gz \
          URI-1.56.tar.gz \
          parent-0.223.tar.gz \
          Params-Validate-0.95.tar.gz \
          Moose-1.15.tar.gz \
          MooseX-MethodAttributes-0.24.tar.gz \
          MooseX-Role-WithOverloading-0.08.tar.gz \
          Monitoring-Livestatus-0.60.tar.gz \
          Monitoring-Livestatus-Class-0.03.tar.gz \
          Monitoring-Availability-0.14.tar.gz \
          MIME-Types-1.31.tar.gz \
          HTTP-Body-1.09.tar.gz \
          libwww-perl-5.837.tar.gz \
          GD-2.45.tar.gz \
          Config-Any-0.20.tar.gz \
          Template-Toolkit-2.22.tar.gz \
          Class-C3-0.23.tar.gz \
          Algorithm-C3-0.08.tar.gz \
          Time-HiRes-1.9721.tar.gz \
          Date-Calc-6.3.tar.gz \
          Data-Page-2.02.tar.gz \
          HTML-Parser-3.68.tar.gz \
          File-Slurp-9999.13.tar.gz \
          Date-Manip-6.12.tar.gz \
          Excel-Template-0.32.tar.gz \
          Class-Accessor-0.34.tar.gz \
          Log-Dispatch-2.26.tar.gz \
          Devel-StackTrace-1.25.tar.gz \
          Catalyst-Runtime-5.80029.tar.gz \
          Catalyst-Action-RenderView-0.14.tar.gz \
          Catalyst-Plugin-ConfigLoader-0.30.tar.gz \
          Catalyst-Plugin-Static-Simple-0.29.tar.gz \
          Catalyst-Plugin-StackTrace-0.11.tar.gz \
          Catalyst-View-TT-0.35.tar.gz \
          Catalyst-View-GD-0.01.tar.gz \
          Catalyst-View-JSON-0.31.tar.gz \
          Catalyst-View-Excel-Template-Plus-0.03.tar.gz \
          Catalyst-Plugin-Authentication-0.10016.tar.gz \
          Catalyst-Plugin-Authorization-Roles-0.08.tar.gz \
          Catalyst-Plugin-CustomErrorMessage-0.06.tar.gz \
          Catalyst-Plugin-Compress-Zlib-0.05.tar.gz \
          Catalyst-Plugin-Unicode-Encoding-1.1.tar.gz \
          Catalyst-Plugin-Cache-0.10.tar.gz \
          Catalyst-Log-Log4perl-1.04.tar.gz \
          Catalyst-Devel-1.28.tar.gz \
          FCGI-0.71.tar.gz \
          FCGI-ProcManager-0.19.tar.gz \
          FCGI-ProcManager-MaxRequests-0.02.tar.gz \
          Module-Find-0.10.tar.gz \
          Catalyst-Plugin-Redirect-0.02.tar.gz


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
