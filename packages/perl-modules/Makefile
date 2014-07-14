include ../../Makefile.omd

NAME     = perl-modules
VERSION  = $(OMD_VERSION)
DISTRO   = $(shell ../../distro)

MODULES = \
          ExtUtils-MakeMaker-6.72.tar.gz \
          autodie-2.25.tar.gz \
          Any-Moose-0.21.tar.gz \
          AppConfig-1.66.tar.gz \
          Attribute-Handlers-0.93.tar.gz \
          B-Keywords-1.13.tar.gz \
          CPAN-1.9402.tar.gz \
          Capture-Tiny-0.22.tar.gz \
          Carp-Clan-6.04.tar.gz \
          Class-Accessor-0.34.tar.gz \
          Class-C3-XS-0.13.tar.gz \
          Class-Data-Inheritable-0.08.tar.gz \
          Class-Inspector-1.28.tar.gz \
          Class-Method-Modifiers-2.04.tar.gz \
          Class-MethodMaker-2.18.tar.gz \
          Class-Singleton-1.4.tar.gz \
          Clone-0.34.tar.gz \
          Compress-Raw-Bzip2-2.062.tar.gz \
          Compress-Raw-Zlib-2.062.tar.gz \
          Config-General-2.52.tar.gz \
          Config-Tiny-2.14.tar.gz \
          Crypt-Blowfish_PP-1.12.tar.gz \
          Crypt-RC4-2.02.tar.gz \
          Crypt-Rijndael-1.11.tar.gz \
          DBI-1.631.tar.gz \
          Data-Dump-1.22.tar.gz \
          Data-Dumper-2.145.tar.gz \
          Devel-PPPort-3.21.tar.gz \
          Devel-StackTrace-1.30.tar.gz \
          Devel-StackTrace-AsHTML-0.14.tar.gz \
          Digest-1.17.tar.gz \
          Digest-MD5-2.53.tar.gz \
          Digest-Perl-MD5-1.8.tar.gz \
          Digest-SHA1-2.13.tar.gz \
          Email-Address-1.900.tar.gz \
          Encode-2.52.tar.gz \
          Encode-Locale-1.03.tar.gz \
          Exception-Class-1.37.tar.gz \
          Exporter-5.68.tar.gz \
          ExtUtils-Config-0.007.tar.gz \
          ExtUtils-Constant-0.23.tar.gz \
          ExtUtils-Depends-0.304.tar.gz \
          ExtUtils-InstallPaths-0.009.tar.gz \
          ExtUtils-Manifest-1.61.tar.gz \
          ExtUtils-PkgConfig-1.14.tar.gz \
          FCGI-0.74.tar.gz \
          FCGI-ProcManager-0.24.tar.gz \
          FCGI-ProcManager-MaxRequests-0.02.tar.gz \
          File-Compare-1.1001.tar.gz \
          File-Copy-Recursive-0.38.tar.gz \
          File-Path-2.09.tar.gz \
          File-ShareDir-1.03.tar.gz \
          File-ShareDir-Install-0.04.tar.gz \
          File-Slurp-9999.19.tar.gz \
          File-Temp-0.22.tar.gz \
          Filesys-Notify-Simple-0.12.tar.gz \
          Filter-1.49.tar.gz \
          GD-2.50.tar.gz \
          Getopt-Long-2.41.tar.gz \
          HTML-Tagset-3.20.tar.gz \
          HTTP-Date-6.02.tar.gz \
          HTTP-Parser-XS-0.16.tar.gz \
          Hash-MultiValue-0.15.tar.gz \
          Hash-Util-FieldHash-Compat-0.03.tar.gz \
          IO-Compress-2.062.tar.gz \
          IO-String-1.08.tar.gz \
          IO-Zlib-1.10.tar.gz \
          IO-stringy-2.110.tar.gz \
          JSON-2.59.tar.gz \
          JSON-Any-1.30.tar.gz \
          JSON-PP-2.27202.tar.gz \
          LWP-MediaTypes-6.02.tar.gz \
          List-Compare-0.37.tar.gz \
          Locale-Maketext-Simple-0.21.tar.gz \
          Log-Log4perl-1.42.tar.gz \
          MIME-Base64-3.14.tar.gz \
          MIME-Types-2.02.tar.gz \
          Math-Calc-Units-1.07.tar.gz \
          Module-CoreList-2.97.tar.gz \
          Module-Find-0.11.tar.gz \
          Module-Load-0.24.tar.gz \
          Mozilla-CA-20130114.tar.gz \
          NEXT-0.65.tar.gz \
          Net-Curl-0.31.tar.gz \
          Net-HTTP-6.06.tar.gz \
          Net-Server-2.007.tar.gz \
          OLE-Storage_Lite-0.19.tar.gz \
          PAR-Dist-0.49.tar.gz \
          Package-Constants-0.02.tar.gz \
          Package-Stash-XS-0.28.tar.gz \
          PadWalker-1.96.tar.gz \
          Params-Check-0.38.tar.gz \
          Parse-CPAN-Meta-1.4405.tar.gz \
          PathTools-3.40.tar.gz \
          Perl-OSType-1.003.tar.gz \
          Perl-Tidy-20130806.tar.gz \
          Pod-Escapes-1.04.tar.gz \
          Pod-Parser-1.61.tar.gz \
          Pod-Simple-3.28.tar.gz \
          Pod-Spell-1.05.tar.gz \
          Readonly-1.03.tar.gz \
          Safe-Isa-1.000003.tar.gz \
          Scalar-List-Utils-1.31.tar.gz \
          Set-Infinite-0.65.tar.gz \
          Set-Object-1.31.tar.gz \
          Spreadsheet-ParseExcel-0.59.tar.gz \
          Storable-2.45.tar.gz \
          Stream-Buffered-0.02.tar.gz \
          String-CRC32-1.4.tar.gz \
          String-Format-1.17.tar.gz \
          Sub-Exporter-Progressive-0.001010.tar.gz \
          Sub-Identify-0.04.tar.gz \
          Sub-Install-0.926.tar.gz \
          Sub-Name-0.05.tar.gz \
          Sys-SigAction-0.20.tar.gz \
          Sys-Syslog-0.33.tar.gz \
          Task-Weaken-1.04.tar.gz \
          Template-Toolkit-2.25.tar.gz \
          Term-ReadLine-Gnu-1.24.tar.gz \
          Term-ShellUI-0.92.tar.gz \
          Term-Size-0.207.tar.gz \
          TermReadKey-2.30.tar.gz \
          Test-Cmd-1.05.tar.gz \
          Test-Simple-0.98.tar.gz \
          Text-Abbrev-1.02.tar.gz \
          Text-Balanced-2.02.tar.gz \
          Text-PDF-0.29.tar.gz \
          Text-ParseWords-3.29.tar.gz \
          Text-SimpleTable-2.03.tar.gz \
          Text-Tabs+Wrap-2013.0523.tar.gz \
          Thread-Semaphore-2.12.tar.gz \
          Tie-RefHash-1.39.tar.gz \
          Tie-ToObject-0.03.tar.gz \
          Time-HiRes-1.9726.tar.gz \
          Time-Local-1.2300.tar.gz \
          Try-Tiny-0.18.tar.gz \
          UNIVERSAL-isa-1.20120726.tar.gz \
          URI-1.60.tar.gz \
          Variable-Magic-0.52.tar.gz \
          WWW-RobotRules-6.02.tar.gz \
          XML-NamespaceSupport-1.11.tar.gz \
          XML-SAX-Base-1.08.tar.gz \
          XSLoader-0.16.tar.gz \
          YAML-0.84.tar.gz \
          YAML-Syck-1.27.tar.gz \
          YAML-Tiny-1.53.tar.gz \
          base-2.18.tar.gz \
          boolean-0.30.tar.gz \
          common-sense-3.72.tar.gz \
          indirect-0.30.tar.gz \
          libnet-1.23.tar.gz \
          parent-0.226.tar.gz \
          podlators-2.5.1.tar.gz \
          threads-1.87.tar.gz \
          threads-shared-1.43.tar.gz \
          version-0.9903.tar.gz \
          Archive-Tar-1.92.tar.gz \
          Archive-Zip-1.30.tar.gz \
          Bit-Vector-7.3.tar.gz \
          CGI.pm-3.63.tar.gz \
          Cairo-1.103.tar.gz \
          Color-Scheme-1.05.tar.gz \
          DBD-Oracle-1.64.tar.gz \
          DBD-mysql-4.023.tar.gz \
          Date-Calc-6.3.tar.gz \
          Date-Calc-XS-6.3.tar.gz \
          Devel-Caller-2.06.tar.gz \
          Devel-Symdump-2.10.tar.gz \
          Email-Date-Format-1.004.tar.gz \
          Eval-Closure-0.11.tar.gz \
          ExtUtils-Helpers-0.021.tar.gz \
          File-Listing-6.04.tar.gz \
          File-Remove-1.52.tar.gz \
          File-chdir-0.1008.tar.gz \
          Font-TTF-1.02.tar.gz \
          Gearman-1.11.tar.gz \
          HTML-Parser-3.71.tar.gz \
          HTTP-Message-6.06.tar.gz \
          HTTP-Negotiate-6.01.tar.gz \
          HTTP-Request-AsCGI-1.2.tar.gz \
          JSON-XS-2.34.tar.gz \
          MIME-Lite-3.029.tar.gz \
          Math-Complex-1.59.tar.gz \
          Module-Metadata-1.000014.tar.gz \
          Object-Signature-1.07.tar.gz \
          PDF-Reuse-0.35.tar.gz \
          Pod-Coverage-0.23.tar.gz \
          Template-Timer-1.00.tar.gz \
          Term-Clui-1.68.tar.gz \
          Term-ProgressBar-2.14.tar.gz \
          Test-Pod-Coverage-1.08.tar.gz \
          Thread-Queue-3.02.tar.gz \
          Tie-RefHash-Weak-0.09.tar.gz \
          XML-SAX-0.99.tar.gz \
          XML-Simple-2.20.tar.gz \
          HTML-Lint-2.20.tar.gz \
          HTTP-Cookies-6.01.tar.gz \
          HTTP-Daemon-6.01.tar.gz \
          Module-Load-Conditional-0.54.tar.gz \
          Monitoring-Livestatus-0.74.tar.gz \
          XML-LibXML-2.0102.tar.gz \
          libwww-perl-6.05.tar.gz \
          IPC-Cmd-0.84.tar.gz \
          LWP-Protocol-Net-Curl-0.018.tar.gz \
          LWP-Protocol-https-6.04.tar.gz \
          XML-Parser-2.41.tar.gz \
          XML-Twig-3.44.tar.gz \
          Crypt-SSLeay-0.64.tar.gz \
          ExtUtils-CBuilder-0.280205.tar.gz \
          ExtUtils-ParseXS-3.21.tar.gz \
          IO-1.25.tar.gz \
          List-MoreUtils-0.33.tar.gz \
          Module-Build-0.4007.tar.gz \
          Module-Build-Tiny-0.026.tar.gz \
          Module-Pluggable-4.8.tar.gz \
          Module-Runtime-0.013.tar.gz \
          Module-ScanDeps-1.10.tar.gz \
          Params-Util-1.07.tar.gz \
          Parse-RecDescent-1.967009.tar.gz \
          Path-Class-0.32.tar.gz \
          Socket-2.011.tar.gz \
          Spreadsheet-WriteExcel-2.39.tar.gz \
          Test-Pod-1.48.tar.gz \
          Tie-IxHash-1.23.tar.gz \
          Tree-Simple-1.18.tar.gz \
          Tree-Simple-VisitorFactory-0.10.tar.gz \
          aliased-0.31.tar.gz \
          constant-1.27.tar.gz \
          Algorithm-C3-0.08.tar.gz \
          CGI-Simple-1.113.tar.gz \
          Class-Accessor-Chained-0.01.tar.gz \
          Class-C3-0.25.tar.gz \
          Color-Library-0.021.tar.gz \
          Config-Any-0.23.tar.gz \
          Data-OptList-0.108.tar.gz \
          Data-Page-2.02.tar.gz \
          Data-Types-0.09.tar.gz \
          Date-Manip-6.40.tar.gz \
          Devel-GlobalDestruction-0.11.tar.gz \
          Dist-CheckConflicts-0.09.tar.gz \
          Error-0.17020.tar.gz \
          Excel-Template-0.34.tar.gz \
          File-BOM-0.14.tar.gz \
          File-SearchPath-0.06.tar.gz \
          HTTP-Body-1.17.tar.gz \
          MRO-Compat-0.12.tar.gz \
          Module-Implementation-0.07.tar.gz \
          Module-Install-1.06.tar.gz \
          PPI-1.215.tar.gz \
          PPIx-Regexp-0.034.tar.gz \
          PPIx-Utilities-1.001000.tar.gz \
          Package-DeprecationManager-0.13.tar.gz \
          Package-Stash-0.35.tar.gz \
          Params-Validate-1.08.tar.gz \
          Perl-Critic-1.118.tar.gz \
          Perl-Critic-Deprecated-1.108.tar.gz \
          Perl-Critic-Dynamic-0.05.tar.gz \
          Perl-Critic-Nits-v1.0.0.tar.gz \
          Perl-Critic-Policy-Dynamic-NoIndirect-0.06.tar.gz \
          Plack-1.0028.tar.gz \
          Plack-Middleware-ReverseProxy-0.15.tar.gz \
          Plack-Test-ExternalServer-0.01.tar.gz \
          Starman-0.4006.tar.gz \
          Sub-Exporter-0.986.tar.gz \
          Test-Perl-Critic-1.02.tar.gz \
          B-Hooks-EndOfScope-0.12.tar.gz \
          Catalyst-Plugin-CustomErrorMessage-0.06.tar.gz \
          Check-ISA-0.04.tar.gz \
          Class-C3-Adopt-NEXT-0.13.tar.gz \
          Class-Load-0.20.tar.gz \
          Class-Load-XS-0.06.tar.gz \
          DateTime-Locale-0.45.tar.gz \
          DateTime-TimeZone-1.60.tar.gz \
          Getopt-Long-Descriptive-0.093.tar.gz \
          Log-Dispatch-2.41.tar.gz \
          Moose-2.1005.tar.gz \
          MooseX-Aliases-0.11.tar.gz \
          MooseX-AttributeHelpers-0.23.tar.gz \
          MooseX-Param-0.02.tar.gz \
          MooseX-Params-Validate-0.18.tar.gz \
          MooseX-Role-Parameterized-1.00.tar.gz \
          MooseX-SemiAffordanceAccessor-0.09.tar.gz \
          Nagios-Plugin-0.36.tar.gz \
          Monitoring-Plugin-0.37.tar.gz \
          String-RewritePrefix-0.006.tar.gz \
          Text-Flow-0.01.tar.gz \
          namespace-clean-0.24.tar.gz \
          Data-Visitor-0.30.tar.gz \
          DateTime-1.03.tar.gz \
          DateTime-Set-0.31.tar.gz \
          Excel-Template-Plus-0.05.tar.gz \
          MongoDB-0.45.tar.gz \
          Monitoring-Livestatus-Class-0.04.tar.gz \
          MooseX-Clone-0.05.tar.gz \
          MooseX-Emulate-Class-Accessor-Fast-0.00903.tar.gz \
          MooseX-Getopt-0.56.tar.gz \
          MooseX-Storage-0.39.tar.gz \
          MooseX-Types-0.36.tar.gz \
          MooseX-Types-Path-Class-0.06.tar.gz \
          namespace-autoclean-0.13.tar.gz \
          File-ChangeNotify-0.23.tar.gz \
          Forest-0.09.tar.gz \
          Geometry-Primitive-0.22.tar.gz \
          Graphics-Color-0.29.tar.gz \
          Graphics-Primitive-0.61.tar.gz \
          Graphics-Primitive-Driver-Cairo-0.44.tar.gz \
          Layout-Manager-0.34.tar.gz \
          MooseX-Daemonize-0.18.tar.gz \
          MooseX-MethodAttributes-0.28.tar.gz \
          MooseX-Role-WithOverloading-0.13.tar.gz \
          Catalyst-Runtime-5.90042.tar.gz \
          Catalyst-View-Excel-Template-Plus-0.03.tar.gz \
          Catalyst-View-GD-0.01.tar.gz \
          Catalyst-View-JSON-0.33.tar.gz \
          Catalyst-View-TT-0.41.tar.gz \
          Chart-Clicker-2.86.tar.gz \
          Catalyst-Action-RenderView-0.16.tar.gz \
          Catalyst-Plugin-Cache-0.12.tar.gz \
          Catalyst-Plugin-Compress-0.005.tar.gz \
          Catalyst-Plugin-ConfigLoader-0.32.tar.gz \
          Catalyst-Plugin-Redirect-0.02.tar.gz \
          Catalyst-Plugin-Session-0.37.tar.gz \
          Catalyst-Plugin-StackTrace-0.12.tar.gz \
          Catalyst-Plugin-Static-Simple-0.30.tar.gz \
          Catalyst-View-PDF-Reuse-0.04.tar.gz \
          Catalyst-Devel-1.39.tar.gz \
          Catalyst-Plugin-Authentication-0.10023.tar.gz \
          Catalyst-Plugin-Authorization-Roles-0.09.tar.gz




build:
	mkdir -p $(P5TMPDIST)/dest ; mkdir -p $(P5TMPDIST)/src
	rsync -av src/. $(P5TMPDIST)/src/.
	rsync -av build_module.pl lib/BuildHelper.pm lib/Module $(P5TMPDIST)/src/.
	echo "install --install_base $(P5TMPDIST)/dest" > $(P5TMPDIST)/dest/.modulebuildrc
	unset LANG; \
	unset PERL5LIB; \
	unset PERL_MB_OPT; \
	unset PERL_LOCAL_LIB_ROOT; \
	unset PERL_MM_OPT; \
	cd $(P5TMPDIST)/src && \
	    PATH=$(P5TMPDIST)/dest/bin:$$PATH \
	    PERL_MM_OPT=INSTALL_BASE=$(P5TMPDIST)/dest \
	    PERL_MB_OPT=--install_base=$(P5TMPDIST)/dest \
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
	rsync -a $(P5TMPDIST)/dest/bin $(DESTDIR)$(OMD_ROOT)/lib/perl5/
	mkdir -p $(DESTDIR)$(OMD_ROOT)/local/lib/perl5
	install -m 755 bin/cpan.wrapper $(DESTDIR)$(OMD_ROOT)/bin/cpan.wrapper

skel:
	echo "install  --install_base  ###ROOT###/local/lib/perl5" > $(SKEL)/.modulebuildrc

clean:
	rm -rf src/inc $(P5TMPDIST)
