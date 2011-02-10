include ../../Makefile.omd

NAME     = perl-modules
VERSION  = $(OMD_VERSION)
PERLARCH = $(shell $(PERL) -e 'use Config; print $$Config{archname}')
TMPDIST  = $(shell pwd)/dist


MODULES = ExtUtils-MakeMaker-6.56.tar.gz \
          ExtUtils-CBuilder-0.280202.tar.gz \
          ExtUtils-ParseXS-2.2206.tar.gz \
          version-0.88.tar.gz \
          Module-CoreList-2.44.tar.gz \
          Perl-OSType-1.002.tar.gz \
          Module-Metadata-1.000004.tar.gz \
          Module-Build-0.3624.tar.gz \
          ExtUtils-Install-1.54.tar.gz \
          CPAN-1.9402.tar.gz \
          File-Remove-1.42.tar.gz \
          Module-ScanDeps-0.98.tar.gz \
          PAR-Dist-0.47.tar.gz \
          YAML-0.72.tar.gz \
          YAML-Tiny-1.48.tar.gz \
          Scalar-List-Utils-1.23.tar.gz \
          common-sense-3.4.tar.gz \
          JSON-2.50.tar.gz \
          JSON-XS-2.3.tar.gz \
          Params-Util-1.03.tar.gz \
          Sub-Install-0.925.tar.gz \
          Data-OptList-0.106.tar.gz \
          Sub-Exporter-0.982.tar.gz \
          Compress-Raw-Zlib-2.033.tar.gz \
          Sub-Uplevel-0.22.tar.gz \
          Variable-Magic-0.46.tar.gz \
          Path-Class-0.23.tar.gz \
          Config-General-2.50.tar.gz \
          B-Hooks-EndOfScope-0.09.tar.gz \
          Sub-Identify-0.04.tar.gz \
          threads-1.82.tar.gz \
          Test-Tester-0.107.tar.gz \
          Test-NoWarnings-1.02.tar.gz \
          File-Copy-Recursive-0.38.tar.gz \
          URI-1.58.tar.gz \
          parent-0.224.tar.gz \
          Params-Validate-0.95.tar.gz \
          Storable-2.25.tar.gz \
          Sub-Name-0.05.tar.gz \
          Task-Weaken-1.03.tar.gz \
          Test-Exception-0.31.tar.gz \
          Test-Requires-0.06.tar.gz \
          Try-Tiny-0.09.tar.gz \
          Tree-DAG_Node-1.06.tar.gz \
          Test-Warn-0.22.tar.gz \
          Package-DeprecationManager-0.10.tar.gz \
          aliased-0.30.tar.gz \
          Package-Stash-0.25.tar.gz \
          namespace-clean-0.20.tar.gz \
          Test-Deep-0.108.tar.gz \
          HTML-Tagset-3.20.tar.gz \
          AppConfig-1.66.tar.gz \
          Carp-Clan-6.04.tar.gz \
          Bit-Vector-7.1.tar.gz \
          Scope-Guard-0.20.tar.gz \
          Devel-GlobalDestruction-0.03.tar.gz \
          MRO-Compat-0.11.tar.gz \
          Class-MOP-1.12.tar.gz \
          Moose-1.21.tar.gz \
          MooseX-Types-0.25.tar.gz \
          namespace-autoclean-0.12.tar.gz \
          MooseX-MethodAttributes-0.24.tar.gz \
          MooseX-Role-WithOverloading-0.09.tar.gz \
          Module-Find-0.10.tar.gz \
          threads-shared-1.36.tar.gz \
          Thread-Queue-2.12.tar.gz \
          Test-Simple-0.96.tar.gz \
          MIME-Types-1.31.tar.gz \
          HTML-Parser-3.68.tar.gz \
          libwww-perl-5.837.tar.gz \
          HTTP-Body-1.11.tar.gz \
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
          Date-Manip-6.21.tar.gz \
          OLE-Storage_Lite-0.19.tar.gz \
          Parse-RecDescent-1.965001.tar.gz \
          Spreadsheet-WriteExcel-2.37.tar.gz \
          IO-stringy-2.110.tar.gz \
          XML-Parser-2.40.tar.gz \
          Excel-Template-0.32.tar.gz \
          Class-Accessor-0.34.tar.gz \
          Log-Dispatch-2.28.tar.gz \
          Devel-StackTrace-1.27.tar.gz \
          CGI-Simple-1.113.tar.gz \
          Class-C3-Adopt-NEXT-0.13.tar.gz \
          Class-Data-Inheritable-0.08.tar.gz \
          Data-Dump-1.19.tar.gz \
          HTTP-Request-AsCGI-1.2.tar.gz \
          MooseX-Emulate-Class-Accessor-Fast-0.00903.tar.gz \
          Getopt-Long-2.38.tar.gz \
          Getopt-Long-Descriptive-0.089.tar.gz \
          MooseX-Getopt-0.35.tar.gz \
          MooseX-Types-Common-0.001002.tar.gz \
          String-RewritePrefix-0.006.tar.gz \
          Text-SimpleTable-2.03.tar.gz \
          Tree-Simple-1.18.tar.gz \
          Tree-Simple-VisitorFactory-0.10.tar.gz \
          Test-use-ok-0.02.tar.gz \
          Tie-ToObject-0.03.tar.gz \
          Data-Visitor-0.27.tar.gz \
          Template-Timer-1.00.tar.gz \
          JSON-Any-1.25.tar.gz \
          Class-Inspector-1.25.tar.gz \
          Object-Signature-1.05.tar.gz \
          Set-Object-1.28.tar.gz \
          UNIVERSAL-isa-1.03.tar.gz \
          Log-Log4perl-1.31.tar.gz \
          MooseX-SemiAffordanceAccessor-0.08.tar.gz \
          MooseX-Params-Validate-0.16.tar.gz \
          Devel-Caller-2.05.tar.gz \
          PadWalker-1.92.tar.gz \
          File-ChangeNotify-0.19.tar.gz \
          File-ShareDir-1.03.tar.gz \
          Spreadsheet-ParseExcel-0.58.tar.gz \
          IO-String-1.08.tar.gz \
          MooseX-Param-0.02.tar.gz \
          List-MoreUtils-0.30.tar.gz \
          Excel-Template-Plus-0.05.tar.gz \
          Module-Pluggable-3.9.tar.gz \
          IO-Compress-2.033.tar.gz \
          Catalyst-Runtime-5.80031.tar.gz \
          Catalyst-Action-RenderView-0.16.tar.gz \
          Catalyst-Plugin-Session-0.31.tar.gz \
          Catalyst-Plugin-ConfigLoader-0.30.tar.gz \
          Catalyst-Plugin-Static-Simple-0.29.tar.gz \
          Catalyst-Plugin-StackTrace-0.11.tar.gz \
          Catalyst-View-TT-0.36.tar.gz \
          Catalyst-View-GD-0.01.tar.gz \
          Catalyst-View-JSON-0.32.tar.gz \
          Catalyst-View-Excel-Template-Plus-0.03.tar.gz \
          Catalyst-Plugin-Authentication-0.10017.tar.gz \
          Catalyst-Plugin-Authorization-Roles-0.08.tar.gz \
          Catalyst-Plugin-CustomErrorMessage-0.06.tar.gz \
          Catalyst-Plugin-Compress-Zlib-0.05.tar.gz \
          Catalyst-Plugin-Unicode-Encoding-1.1.tar.gz \
          Catalyst-Plugin-Cache-0.10.tar.gz \
          Catalyst-Log-Log4perl-1.04.tar.gz \
          Catalyst-Devel-1.31.tar.gz \
          FCGI-0.71.tar.gz \
          FCGI-ProcManager-0.19.tar.gz \
          FCGI-ProcManager-MaxRequests-0.02.tar.gz \
          Catalyst-Plugin-Redirect-0.02.tar.gz \
          Monitoring-Livestatus-0.64.tar.gz \
          Monitoring-Livestatus-Class-0.03.tar.gz \
          Monitoring-Availability-0.16.tar.gz \
          YAML-Syck-1.17.tar.gz \
          Math-Calc-Units-1.07.tar.gz \
          Config-Tiny-2.13.tar.gz \
          Nagios-Plugin-0.35.tar.gz \
          Term-ShellUI-0.86.tar.gz \
          Term-Size-0.207.tar.gz \
          TermReadKey-2.30.tar.gz \
          Term-Clui-1.64.tar.gz \
          File-SearchPath-0.06.tar.gz \
          Term-ReadLine-Gnu-1.20.tar.gz \
          DBI-1.616.tar.gz \
          DBD-mysql-4.018.tar.gz \
          DBD-Oracle-1.27.tar.gz \
          Crypt-SSLeay-0.58.tar.gz \
          XML-NamespaceSupport-1.11.tar.gz \
          XML-SAX-0.96.tar.gz \
          XML-Simple-2.18.tar.gz \
          Error-0.17016.tar.gz \
          Encode-2.42.tar.gz \
          Date-Calc-XS-6.2.tar.gz \
          HTML-Lint-2.06.tar.gz

build:
	mkdir -p $(TMPDIST)
	echo "install --install_base $(TMPDIST)" > $(TMPDIST)/.modulebuildrc
	cd src && PERL_MM_OPT=INSTALL_BASE=$(TMPDIST) MODULEBUILDRC=$(TMPDIST)/.modulebuildrc PERL5LIB=$(TMPDIST)/lib/perl5:$(TMPDIST)/lib/perl5/$(PERLARCH) ./build_module.pl $(PERL) $(MODULES)
	rm -rf src/inc
	cd $(TMPDIST)/lib/perl5/ && rm -f utils.pm && ln -s ../../../nagios/plugins/utils.pm .
	mkdir -p $(TMPDIST)/lib/perl5/CPAN
	cp MyConfig.pm $(TMPDIST)/lib/perl5/CPAN/MyConfig.pm

install:
	if [ -z $(DESTDIR) ]; then echo "cannot install without DESTDIR set!"; exit 1; fi
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/perl5
	rsync -a $(TMPDIST)/lib $(DESTDIR)$(OMD_ROOT)/lib/perl5/
	mkdir -p $(DESTDIR)$(OMD_ROOT)/local/lib/perl5

skel:
	echo "install  --install_base  ###ROOT###/local/lib/perl5" > $(SKEL)/.modulebuildrc

clean:
	rm -rf src/inc $(TMPDIST)

test:
	cd src && PERL_MM_OPT=INSTALL_BASE=$(TMPDIST) MODULEBUILDRC=$(TMPDIST)/.modulebuildrc PERL5LIB=$(TMPDIST)/lib/perl5:$(TMPDIST)/lib/perl5/$(PERLARCH) ./build_module.pl $(PERL) testonly $(MODULES);
