include ../../Makefile.omd

NAME     = perl-modules
VERSION  = $(OMD_VERSION)
DISTRO   = $(shell ../../distro)

MODULES = \
          ExtUtils-MakeMaker-6.64.tar.gz \
          AppConfig-1.66.tar.gz \
          Attribute-Handlers-0.93.tar.gz \
          B-Keywords-1.12.tar.gz \
          CPAN-1.9402.tar.gz \
          CPAN-Meta-YAML-0.008.tar.gz \
          Capture-Tiny-0.21.tar.gz \
          Carp-Clan-6.04.tar.gz \
          Class-Accessor-0.34.tar.gz \
          Class-C3-XS-0.13.tar.gz \
          Class-Data-Inheritable-0.08.tar.gz \
          Class-Inspector-1.28.tar.gz \
          Class-MethodMaker-2.18.tar.gz \
          Class-Singleton-1.4.tar.gz \
          Clone-0.34.tar.gz \
          Compress-Raw-Bzip2-2.060.tar.gz \
          Compress-Raw-Zlib-2.060.tar.gz \
          Config-General-2.51.tar.gz \
          Config-Tiny-2.14.tar.gz \
          Crypt-Blowfish_PP-1.12.tar.gz \
          Crypt-RC4-2.02.tar.gz \
          Crypt-Rijndael-1.11.tar.gz \
          Crypt-SSLeay-0.64.tar.gz \
          DBI-1.623.tar.gz \
          Data-Dump-1.21.tar.gz \
          Data-Dumper-2.139.tar.gz \
          Devel-PPPort-3.20.tar.gz \
          Devel-StackTrace-1.30.tar.gz \
          Devel-StackTrace-AsHTML-0.11.tar.gz \
          Devel-Symdump-2.08.tar.gz \
          Digest-1.17.tar.gz \
          Digest-MD5-2.52.tar.gz \
          Digest-Perl-MD5-1.8.tar.gz \
          Digest-SHA1-2.13.tar.gz \
          Email-Address-1.897.tar.gz \
          Encode-2.47.tar.gz \
          Encode-Locale-1.03.tar.gz \
          Exception-Class-1.36.tar.gz \
          Exporter-5.67.tar.gz \
          ExtUtils-Constant-0.23.tar.gz \
          ExtUtils-Manifest-1.61.tar.gz \
          ExtUtils-PkgConfig-1.13.tar.gz \
          FCGI-0.74.tar.gz \
          FCGI-ProcManager-0.24.tar.gz \
          FCGI-ProcManager-MaxRequests-0.02.tar.gz \
          File-Compare-1.1001.tar.gz \
          File-Copy-Recursive-0.38.tar.gz \
          File-Path-2.09.tar.gz \
          File-ShareDir-1.03.tar.gz \
          File-Slurp-9999.19.tar.gz \
          File-Temp-0.22.tar.gz \
          Filesys-Notify-Simple-0.08.tar.gz \
          Filter-1.45.tar.gz \
          Font-TTF-1.02.tar.gz \
          GD-2.46.tar.gz \
          Getopt-Long-2.38.tar.gz \
          HTML-Tagset-3.20.tar.gz \
          HTTP-Date-6.02.tar.gz \
          HTTP-Parser-XS-0.15.tar.gz \
          Hash-MultiValue-0.13.tar.gz \
          IO-1.25.tar.gz \
          IO-Compress-2.060.tar.gz \
          IO-String-1.08.tar.gz \
          IO-Zlib-1.10.tar.gz \
          IO-stringy-2.110.tar.gz \
          JSON-2.53.tar.gz \
          JSON-PP-2.27200.tar.gz \
          LWP-MediaTypes-6.02.tar.gz \
          List-Compare-0.37.tar.gz \
          Locale-Maketext-Simple-0.21.tar.gz \
          Log-Log4perl-1.40.tar.gz \
          MIME-Base64-3.13.tar.gz \
          MIME-Types-1.38.tar.gz \
          Math-Calc-Units-1.07.tar.gz \
          Math-Round-0.06.tar.gz \
          Module-CoreList-2.79.tar.gz \
          Module-Find-0.11.tar.gz \
          Module-Load-0.22.tar.gz \
          Monitoring-Availability-0.42.tar.gz \
          NEXT-0.65.tar.gz \
          Net-HTTP-6.05.tar.gz \
          Net-Server-2.007.tar.gz \
          OLE-Storage_Lite-0.19.tar.gz \
          PAR-Dist-0.49.tar.gz \
          PDF-API2-2.019.tar.gz \
          Package-Constants-0.02.tar.gz \
          Package-Stash-XS-0.26.tar.gz \
          PadWalker-1.96.tar.gz \
          Params-Check-0.36.tar.gz \
          Parse-CPAN-Meta-1.4404.tar.gz \
          PathTools-3.40.tar.gz \
          Perl-OSType-1.002.tar.gz \
          Perl-Tidy-20121207.tar.gz \
          Pod-Coverage-0.22.tar.gz \
          Pod-Escapes-1.04.tar.gz \
          Pod-Parser-1.51.tar.gz \
          Pod-Simple-3.23.tar.gz \
          Pod-Spell-1.01.tar.gz \
          Readonly-1.03.tar.gz \
          Scalar-List-Utils-1.27.tar.gz \
          Set-Infinite-0.65.tar.gz \
          Set-Object-1.28.tar.gz \
          Spreadsheet-ParseExcel-0.59.tar.gz \
          Storable-2.39.tar.gz \
          String-CRC32-1.4.tar.gz \
          String-Format-1.17.tar.gz \
          Sub-Identify-0.04.tar.gz \
          Sub-Install-0.926.tar.gz \
          Sub-Name-0.05.tar.gz \
          Sys-Syslog-0.32.tar.gz \
          Task-Weaken-1.04.tar.gz \
          Template-Toolkit-2.24.tar.gz \
          Term-ReadLine-Gnu-1.20.tar.gz \
          Term-ShellUI-0.92.tar.gz \
          Term-Size-0.207.tar.gz \
          TermReadKey-2.30.tar.gz \
          Test-Cmd-1.05.tar.gz \
          Test-Pod-Coverage-1.08.tar.gz \
          Test-Simple-0.98.tar.gz \
          Text-Abbrev-1.02.tar.gz \
          Text-Balanced-2.02.tar.gz \
          Text-PDF-0.29.tar.gz \
          Text-ParseWords-3.27.zip \
          Text-SimpleTable-2.03.tar.gz \
          Text-Tabs+Wrap-2012.0818.tar.gz \
          Thread-Semaphore-2.12.tar.gz \
          Tie-RefHash-1.39.tar.gz \
          Tie-ToObject-0.03.tar.gz \
          Time-HiRes-1.9725.tar.gz \
          Time-Local-1.2300.tar.gz \
          Try-Tiny-0.12.tar.gz \
          UNIVERSAL-isa-1.20120726.tar.gz \
          URI-1.60.tar.gz \
          Variable-Magic-0.52.tar.gz \
          WWW-RobotRules-6.02.tar.gz \
          XML-NamespaceSupport-1.11.tar.gz \
          XML-SAX-Base-1.08.tar.gz \
          XSLoader-0.16.tar.gz \
          YAML-0.84.tar.gz \
          YAML-Syck-1.22.tar.gz \
          YAML-Tiny-1.51.tar.gz \
          base-2.18.tar.gz \
          common-sense-3.6.tar.gz \
          indirect-0.26.tar.gz \
          libnet-1.22.tar.gz \
          parent-0.225.tar.gz \
          podlators-2.5.0.tar.gz \
          threads-1.86.tar.gz \
          threads-shared-1.43.tar.gz \
          version-0.9901.tar.gz \
          Archive-Tar-1.90.tar.gz \
          Archive-Zip-1.30.tar.gz \
          Bit-Vector-7.2.tar.gz \
          CGI.pm-3.63.tar.gz \
          CPAN-Meta-Requirements-2.122.tar.gz \
          ExtUtils-Depends-0.304.tar.gz \
          Cairo-1.090.tar.gz \
          Color-Scheme-1.04.tar.gz \
          DBD-Oracle-1.56.tar.gz \
          DBD-mysql-4.022.tar.gz \
          Date-Calc-6.3.tar.gz \
          Date-Calc-XS-6.3.tar.gz \
          Devel-Caller-2.06.tar.gz \
          File-Listing-6.04.tar.gz \
          File-Remove-1.52.tar.gz \
          File-chdir-0.1008.tar.gz \
          Gearman-1.11.tar.gz \
          HTML-Parser-3.69.tar.gz \
          HTTP-Message-6.06.tar.gz \
          HTTP-Negotiate-6.01.tar.gz \
          HTTP-Request-AsCGI-1.2.tar.gz \
          JSON-XS-2.33.tar.gz \
          Math-Complex-1.59.tar.gz \
          Module-Load-Conditional-0.54.tar.gz \
          Module-Metadata-1.000011.tar.gz \
          Object-Signature-1.07.tar.gz \
          PDF-Reuse-0.35.tar.gz \
          Template-Timer-1.00.tar.gz \
          Term-Clui-1.66.tar.gz \
          Term-ProgressBar-2.13.tar.gz \
          Thread-Queue-3.01.tar.gz \
          Tie-RefHash-Weak-0.09.tar.gz \
          XML-SAX-0.99.tar.gz \
          XML-Simple-2.20.tar.gz \
          CPAN-Meta-2.120921.tar.gz \
          Color-Library-0.021.tar.gz \
          Config-Any-0.23.tar.gz \
          HTML-Lint-2.20.tar.gz \
          HTTP-Body-1.17.tar.gz \
          HTTP-Cookies-6.01.tar.gz \
          HTTP-Daemon-6.01.tar.gz \
          Hash-Util-FieldHash-Compat-0.03.tar.gz \
          IPC-Cmd-0.78.tar.gz \
          JSON-Any-1.29.tar.gz \
          Monitoring-Livestatus-0.74.tar.gz \
          XML-LibXML-2.0014.tar.gz \
          libwww-perl-6.04.tar.gz \
          ExtUtils-CBuilder-0.280205.tar.gz \
          ExtUtils-ParseXS-3.18.tar.gz \
          List-MoreUtils-0.33.tar.gz \
          Module-Build-0.4003.tar.gz \
          Module-Pluggable-4.5.tar.gz \
          Module-Runtime-0.013.tar.gz \
          Module-ScanDeps-1.10.tar.gz \
          Params-Util-1.07.tar.gz \
          Parse-RecDescent-1.967009.tar.gz \
          Path-Class-0.29.tar.gz \
          Plack-1.0015.tar.gz \
          Plack-Middleware-ForceEnv-0.02.tar.gz \
          Plack-Middleware-ReverseProxy-0.15.tar.gz \
          Plack-Test-ExternalServer-0.01.tar.gz \
          Socket-2.009.tar.gz \
          Spreadsheet-WriteExcel-2.38.tar.gz \
          Starman-0.3006.tar.gz \
          Test-Pod-1.45.tar.gz \
          Tree-Simple-1.18.tar.gz \
          Tree-Simple-VisitorFactory-0.10.tar.gz \
          XML-Parser-2.41.tar.gz \
          XML-XPath-1.13.tar.gz \
          aliased-0.30.tar.gz \
          constant-1.25.tar.gz \
          Algorithm-C3-0.08.tar.gz \
          CGI-Simple-1.113.tar.gz \
          Class-Accessor-Chained-0.01.tar.gz \
          Class-C3-0.24.tar.gz \
          Data-OptList-0.107.tar.gz \
          Data-Page-2.02.tar.gz \
          Date-Manip-6.38.tar.gz \
          Error-0.17019.tar.gz \
          Excel-Template-0.34.tar.gz \
          ExtUtils-Install-1.54.tar.gz \
          File-BOM-0.14.tar.gz \
          File-SearchPath-0.06.tar.gz \
          MRO-Compat-0.12.tar.gz \
          Math-BaseCnv-1.8.B59BrZX.tgz \
          Module-Implementation-0.06.tar.gz \
          Module-Install-1.06.tar.gz \
          PPI-1.215.tar.gz \
          PPIx-Regexp-0.029.tar.gz \
          PPIx-Utilities-1.001000.tar.gz \
          Package-DeprecationManager-0.13.tar.gz \
          Params-Validate-1.07.tar.gz \
          Perl-Critic-1.118.tar.gz \
          Perl-Critic-Deprecated-1.108.tar.gz \
          Perl-Critic-Dynamic-0.05.tar.gz \
          Perl-Critic-Nits-v1.0.0.tar.gz \
          Perl-Critic-Policy-Dynamic-NoIndirect-0.06.tar.gz \
          Sub-Exporter-0.984.tar.gz \
          Test-Perl-Critic-1.02.tar.gz \
          XML-Twig-3.42.tar.gz \
          B-Hooks-EndOfScope-0.12.tar.gz \
          Catalyst-Plugin-CustomErrorMessage-0.06.tar.gz \
          Check-ISA-0.04.tar.gz \
          Class-C3-Adopt-NEXT-0.13.tar.gz \
          DateTime-Locale-0.45.tar.gz \
          Devel-GlobalDestruction-0.09.tar.gz \
          Dist-CheckConflicts-0.02.tar.gz \
          Eval-Closure-0.08.tar.gz \
          Getopt-Long-Descriptive-0.093.tar.gz \
          Log-Dispatch-2.34.tar.gz \
          Nagios-Plugin-0.36.tar.gz \
          Package-Stash-0.34.tar.gz \
          String-RewritePrefix-0.006.tar.gz \
          namespace-clean-0.24.tar.gz \
          Class-Load-0.20.tar.gz \
          Class-Load-XS-0.06.tar.gz \
          DateTime-TimeZone-1.56.tar.gz \
          Moose-2.0604.tar.gz \
          MooseX-Aliases-0.10.tar.gz \
          MooseX-AttributeHelpers-0.23.tar.gz \
          MooseX-Emulate-Class-Accessor-Fast-0.00903.tar.gz \
          MooseX-Param-0.02.tar.gz \
          MooseX-Params-Validate-0.18.tar.gz \
          MooseX-Role-Parameterized-1.00.tar.gz \
          MooseX-SemiAffordanceAccessor-0.09.tar.gz \
          MooseX-Storage-0.32.tar.gz \
          MooseX-Types-0.35.tar.gz \
          MooseX-Types-Common-0.001008.tar.gz \
          MooseX-Types-LoadableClass-0.008.tar.gz \
          MooseX-Types-Path-Class-0.06.tar.gz \
          Text-Flow-0.01.tar.gz \
          namespace-autoclean-0.13.tar.gz \
          Data-Visitor-0.28.tar.gz \
          DateTime-0.78.tar.gz \
          DateTime-Set-0.31.tar.gz \
          Excel-Template-Plus-0.05.tar.gz \
          File-ChangeNotify-0.22.tar.gz \
          Monitoring-Livestatus-Class-0.04.tar.gz \
          MooseX-Clone-0.05.tar.gz \
          MooseX-Getopt-0.50.tar.gz \
          MooseX-MethodAttributes-0.28.tar.gz \
          MooseX-Role-WithOverloading-0.13.tar.gz \
          Catalyst-Runtime-5.90019.tar.gz \
          Catalyst-View-Excel-Template-Plus-0.03.tar.gz \
          Catalyst-View-GD-0.01.tar.gz \
          Catalyst-View-JSON-0.33.tar.gz \
          Catalyst-View-TT-0.40.tar.gz \
          Forest-0.09.tar.gz \
          Geometry-Primitive-0.22.tar.gz \
          Graphics-Color-0.29.tar.gz \
          Graphics-Primitive-0.61.tar.gz \
          Graphics-Primitive-Driver-Cairo-0.44.tar.gz \
          Layout-Manager-0.34.tar.gz \
          MooseX-Daemonize-0.15.tar.gz \
          Catalyst-Action-RenderView-0.16.tar.gz \
          Catalyst-Plugin-Cache-0.11.tar.gz \
          Catalyst-Plugin-Compress-0.005.tar.gz \
          Catalyst-Plugin-ConfigLoader-0.30.tar.gz \
          Catalyst-Plugin-Redirect-0.02.tar.gz \
          Catalyst-Plugin-Session-0.36.tar.gz \
          Catalyst-Plugin-StackTrace-0.12.tar.gz \
          Catalyst-View-PDF-Reuse-0.04.tar.gz \
          Chart-Clicker-2.83.tar.gz \
          Catalyst-Plugin-Authentication-0.10022.tar.gz \
          Catalyst-Plugin-Authorization-Roles-0.09.tar.gz \
          Catalyst-Plugin-Static-Simple-0.30.tar.gz \
          Catalyst-Devel-1.37.tar.gz \
          Email-Date-Format-1.002.tar.gz \
          MIME-Lite-3.029.tar.gz \
          Class-Method-Modifiers-2.00.tar.gz \
          Data-Types-0.09.tar.gz \
          boolean-0.28.tar.gz \
          Any-Moose-0.20.tar.gz \
          Tie-IxHash-1.22.tar.gz \
          MongoDB-0.45.tar.gz \
          Sub-Exporter-Progressive-0.001001.tar.gz \
          Safe-Isa-1.000002.tar.gz \
          ExtUtils-PkgConfig-1.14.tar.gz \
          Net-Curl-0.25.tar.gz \
          LWP-Protocol-Net-Curl-0.013.tar.gz




build:
	mkdir -p $(P5TMPDIST)/dest mkdir -p $(P5TMPDIST)/src
	rsync -av src/. $(P5TMPDIST)/src/.
	rsync -av build_module.pl lib/BuildHelper.pm lib/Module $(P5TMPDIST)/src/.
	echo "install --install_base $(P5TMPDIST)/dest" > $(P5TMPDIST)/dest/.modulebuildrc
	unset PERL5LIB; \
	unset PERL_MB_OPT; \
	unset PERL_LOCAL_LIB_ROOT; \
	unset PERL_MM_OPT; \
	cd $(P5TMPDIST)/src && \
	    PERL_MM_OPT=INSTALL_BASE=$(P5TMPDIST)/dest \
	    MODULEBUILDRC=$(P5TMPDIST)/dest/.modulebuildrc \
	    PERL5LIB=$(P5TMPDIST)/dest/lib/perl5 \
	    ./build_module.pl -d "$(DISTRO)" -p $(P5TMPDIST)/dest $(MODULES)
	cd $(P5TMPDIST)/dest/lib/perl5/ && rm -f utils.pm && ln -s ../../../nagios/plugins/utils.pm .
	mkdir -p $(P5TMPDIST)/dest/lib/perl5/CPAN
	cp MyConfig.pm $(P5TMPDIST)/dest/lib/perl5/CPAN/MyConfig.skel

install:
	if [ -z $(DESTDIR) ]; then echo "cannot install without DESTDIR set!"; exit 1; fi
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/perl5 $(DESTDIR)$(OMD_ROOT)/bin
	rsync -a $(P5TMPDIST)/dest/lib $(DESTDIR)$(OMD_ROOT)/lib/perl5/
	mkdir -p $(DESTDIR)$(OMD_ROOT)/local/lib/perl5
	install -m 755 bin/cpan.wrapper $(DESTDIR)$(OMD_ROOT)/bin/cpan.wrapper

skel:
	echo "install  --install_base  ###ROOT###/local/lib/perl5" > $(SKEL)/.modulebuildrc

clean:
	rm -rf src/inc $(P5TMPDIST)
