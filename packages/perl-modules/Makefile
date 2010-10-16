include ../../Makefile.omd

NAME     = perl-modules
VERSION  = $(OMD_VERSION)
LLSRC    = $(shell basename src/local-lib-*.gz | sed s/\.tar\.gz// )
PERLARCH = $(shell $(PERL) -e 'use Config; print $$Config{archname}')


MODULES = ExtUtils-MakeMaker-6.56.tar.gz \
          ExtUtils-CBuilder-0.2703.tar.gz \
          ExtUtils-ParseXS-2.2206.tar.gz \
          Module-Build-0.3607.tar.gz \
          ExtUtils-Install-1.54.tar.gz \
          CPAN-1.9402.tar.gz \
          File-Remove-1.42.tar.gz \
          Module-ScanDeps-0.98.tar.gz \
          PAR-Dist-0.47.tar.gz \
          YAML-0.72.tar.gz \
          YAML-Tiny-1.44.tar.gz \
          Scalar-List-Utils-1.23.tar.gz \
          common-sense-3.0.tar.gz \
          JSON-2.26.tar.gz \
          JSON-XS-2.3.tar.gz \
          Params-Util-1.01.tar.gz \
          Sub-Install-0.925.tar.gz \
          Data-OptList-0.106.tar.gz \
          Sub-Exporter-0.982.tar.gz \
          Compress-Raw-Zlib-2.030.tar.gz \
          Sub-Uplevel-0.22.tar.gz \
          Variable-Magic-0.44.tar.gz \
          Path-Class-0.21.tar.gz \
          Config-General-2.49.tar.gz \
          B-Hooks-EndOfScope-0.09.tar.gz \
          Sub-Identify-0.04.tar.gz \
          Test-Tester-0.107.tar.gz \
          Test-NoWarnings-1.02.tar.gz \
          File-Copy-Recursive-0.38.tar.gz \
          URI-1.56.tar.gz \
          parent-0.223.tar.gz \
          Params-Validate-0.95.tar.gz \
          Storable-2.21.tar.gz \
          Sub-Name-0.05.tar.gz \
          Task-Weaken-1.03.tar.gz \
          Test-Exception-0.29.tar.gz \
          Test-Requires-0.06.tar.gz \
          Try-Tiny-0.06.tar.gz \
          Tree-DAG_Node-1.06.tar.gz \
          Test-Warn-0.22.tar.gz \
          Package-DeprecationManager-0.04.tar.gz \
          aliased-0.30.tar.gz \
          Package-Stash-0.08.tar.gz \
          namespace-clean-0.18.tar.gz \
          Test-Deep-0.107.tar.gz \
          HTML-Tagset-3.20.tar.gz \
          AppConfig-1.66.tar.gz \
          Carp-Clan-6.04.tar.gz \
          Bit-Vector-7.1.tar.gz \
          Scope-Guard-0.20.tar.gz \
          Devel-GlobalDestruction-0.02.tar.gz \
          MRO-Compat-0.11.tar.gz \
          Class-MOP-1.09.tar.gz \
          Moose-1.15.tar.gz \
          MooseX-Types-0.24.tar.gz \
          namespace-autoclean-0.11.tar.gz \
          MooseX-MethodAttributes-0.24.tar.gz \
          MooseX-Role-WithOverloading-0.08.tar.gz \
          Module-Find-0.10.tar.gz \
          threads-shared-1.34.tar.gz \
          Thread-Queue-2.11.tar.gz \
          Test-Simple-0.96.tar.gz \
          MIME-Types-1.31.tar.gz \
          HTML-Parser-3.68.tar.gz \
          libwww-perl-5.837.tar.gz \
          HTTP-Body-1.09.tar.gz \
          Module-Install-1.00.tar.gz \
          GD-2.45.tar.gz \
          Config-Any-0.20.tar.gz \
          Template-Toolkit-2.22.tar.gz \
          Class-C3-0.23.tar.gz \
          Algorithm-C3-0.08.tar.gz \
          Time-HiRes-1.9721.tar.gz \
          Date-Calc-6.3.tar.gz \
          Class-Accessor-Chained-0.01.tar.gz \
          Data-Page-2.02.tar.gz \
          File-Slurp-9999.13.tar.gz \
          Date-Manip-6.12.tar.gz \
          OLE-Storage_Lite-0.19.tar.gz \
          Parse-RecDescent-1.965001.tar.gz \
          Spreadsheet-WriteExcel-2.37.tar.gz \
          IO-stringy-2.110.tar.gz \
          XML-Parser-2.40.tar.gz \
          Excel-Template-0.32.tar.gz \
          Class-Accessor-0.34.tar.gz \
          Log-Dispatch-2.26.tar.gz \
          Devel-StackTrace-1.25.tar.gz \
          CGI-Simple-1.112.tar.gz \
          Class-C3-Adopt-NEXT-0.13.tar.gz \
          Class-Data-Inheritable-0.08.tar.gz \
          Data-Dump-1.17.tar.gz \
          HTTP-Request-AsCGI-1.2.tar.gz \
          MooseX-Emulate-Class-Accessor-Fast-0.00903.tar.gz \
          Getopt-Long-2.38.tar.gz \
          Getopt-Long-Descriptive-0.086.tar.gz \
          MooseX-Getopt-0.33.tar.gz \
          MooseX-Types-Common-0.001002.tar.gz \
          String-RewritePrefix-0.005.tar.gz \
          Text-SimpleTable-2.03.tar.gz \
          Tree-Simple-1.18.tar.gz \
          Tree-Simple-VisitorFactory-0.10.tar.gz \
          Test-use-ok-0.02.tar.gz \
          Tie-ToObject-0.03.tar.gz \
          Data-Visitor-0.27.tar.gz \
          Template-Timer-1.00.tar.gz \
          JSON-Any-1.22.tar.gz \
          Class-Inspector-1.24.tar.gz \
          Object-Signature-1.05.tar.gz \
          Set-Object-1.28.tar.gz \
          UNIVERSAL-isa-1.03.tar.gz \
          Log-Log4perl-1.30.tar.gz \
          MooseX-SemiAffordanceAccessor-0.08.tar.gz \
          MooseX-Params-Validate-0.14.tar.gz \
          Devel-Caller-2.05.tar.gz \
          PadWalker-1.92.tar.gz \
          File-ChangeNotify-0.17.tar.gz \
          File-ShareDir-1.02.tar.gz \
          Spreadsheet-ParseExcel-0.58.tar.gz \
          IO-String-1.08.tar.gz \
          MooseX-Param-0.02.tar.gz \
          List-MoreUtils-0.22.tar.gz \
          Excel-Template-Plus-0.05.tar.gz \
          Module-Pluggable-3.9.tar.gz \
          IO-Compress-2.030.tar.gz \
          Catalyst-Runtime-5.80029.tar.gz \
          Catalyst-Action-RenderView-0.14.tar.gz \
          Catalyst-Plugin-Session-0.30.tar.gz \
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
          Catalyst-Plugin-Redirect-0.02.tar.gz \
          Monitoring-Livestatus-0.60.tar.gz \
          Monitoring-Livestatus-Class-0.03.tar.gz \
          Monitoring-Availability-0.14.tar.gz


build:
	test -d dist || mkdir dist
	echo "install  --install_base  $$(pwd)/dist" > dist/.modulebuildrc
	cd src; \
	for tarball in $(MODULES); do \
	    PERL_MM_OPT=INSTALL_BASE=$$(pwd)/../dist MODULEBUILDRC=$$(pwd)/../dist/.modulebuildrc PERL5LIB=$$(pwd)/../dist/lib/perl5:$$(pwd)/../dist/lib/perl5/$(PERLARCH) ../build_module.sh $$tarball $(PERL); \
	    if [ $$? == 0 ]; then \
	        echo "   ok"; \
	    else \
	        echo "   not ok"; \
	        exit 1; \
	    fi; \
	done
	rm -rf src/inc

install:
	if [ -z $(DESTDIR) ]; then echo "cannot install without DESTDIR set!"; exit 1; fi
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/perl5
	cp -rp dist/lib $(DESTDIR)$(OMD_ROOT)/lib/perl5/lib
	cp -rp dist/.modulebuildrc $(DESTDIR)$(OMD_ROOT)/lib/perl5/

skel:

clean:
	rm -rf src/$(LLSRC) src/inc dist

test:
	cd src; \
	for tarball in $(MODULES); do \
	    PERL_MM_OPT=INSTALL_BASE=$$(pwd)/../dist MODULEBUILDRC=$$(pwd)/../dist/.modulebuildrc PERL5LIB=$$(pwd)/../dist/lib/perl5:$$(pwd)/../dist/lib/perl5/$(PERLARCH) ../build_module.sh $$tarball $(PERL) testony; \
	    if [ $$? == 0 ]; then \
	        echo "   ok"; \
	    else \
	        echo "   not ok"; \
	        exit 1; \
	    fi; \
	done
