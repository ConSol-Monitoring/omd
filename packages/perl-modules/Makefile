include ../../Makefile.omd

NAME     = perl-modules
VERSION  = $(OMD_VERSION)
DISTRO   = $(shell ../../distro)

MODULES = \
          AppConfig-1.71.tar.gz \
          Capture-Tiny-0.27.tar.gz \
          Carp-Clan-6.04.tar.gz \
          Class-Accessor-0.34.tar.gz \
          Class-Inspector-1.28.tar.gz \
          Class-Singleton-1.5.tar.gz \
          Compress-Raw-Bzip2-2.068.tar.gz \
          Compress-Raw-Zlib-2.068.tar.gz \
          Config-General-2.56.tar.gz \
          Crypt-Blowfish_PP-1.12.tar.gz \
          Crypt-RC4-2.02.tar.gz \
          Crypt-Rijndael-1.12.tar.gz \
          DBI-1.633.tar.gz \
          Data-Dumper-2.154.tar.gz \
          Digest-1.17.tar.gz \
          Digest-MD5-2.54.tar.gz \
          Digest-Perl-MD5-1.9.tar.gz \
          Digest-SHA1-2.13.tar.gz \
          Email-Date-Format-1.005.tar.gz \
          Encode-Locale-1.04.tar.gz \
          Exporter-5.70.tar.gz \
          Exporter-Tiny-0.042.tar.gz \
          ExtUtils-Config-0.008.tar.gz \
          ExtUtils-Constant-0.23.tar.gz \
          ExtUtils-InstallPaths-0.010.tar.gz \
          ExtUtils-Manifest-1.70.tar.gz \
          FCGI-0.77.tar.gz \
          FCGI-ProcManager-0.25.tar.gz \
          File-Copy-Recursive-0.38.tar.gz \
          File-Path-2.09.tar.gz \
          File-Remove-1.52.tar.gz \
          File-ShareDir-Install-0.10.tar.gz \
          File-Slurp-9999.19.tar.gz \
          GD-2.50.tar.gz \
          Getopt-Long-2.43.tar.gz \
          HTML-Tagset-3.20.tar.gz \
          HTTP-Date-6.02.tar.gz \
          Hash-MultiValue-0.16.tar.gz \
          IO-Compress-2.068.tar.gz \
          IO-String-1.08.tar.gz \
          IO-Zlib-1.10.tar.gz \
          IO-stringy-2.111.tar.gz \
          LWP-MediaTypes-6.02.tar.gz \
          Locale-Maketext-Simple-0.21.tar.gz \
          Log-Log4perl-1.46.tar.gz \
          MIME-Base64-3.15.tar.gz \
          MIME-Lite-3.030.tar.gz \
          Math-Calc-Units-1.07.tar.gz \
          Math-Complex-1.59.tar.gz \
          Module-Find-0.12.tar.gz \
          Module-Load-0.32.tar.gz \
          Mozilla-CA-20141217.tar.gz \
          OLE-Storage_Lite-0.19.tar.gz \
          Package-Stash-XS-0.28.tar.gz \
          Params-Check-0.38.tar.gz \
          PathTools-3.47.tar.gz \
          Perl-OSType-1.008.tar.gz \
          Pod-Escapes-1.07.tar.gz \
          Pod-Simple-3.29.tar.gz \
          Pod-Usage-1.64.tar.gz \
          Scalar-List-Utils-1.42.tar.gz \
          Spreadsheet-ParseExcel-0.65.tar.gz \
          Stream-Buffered-0.03.tar.gz \
          String-CRC32-1.5.tar.gz \
          Sub-Exporter-Progressive-0.001011.tar.gz \
          Sub-Identify-0.10.tar.gz \
          Sub-Install-0.928.tar.gz \
          Sub-Name-0.12.tar.gz \
          Sys-SigAction-0.21.tar.gz \
          Template-Toolkit-2.26.tar.gz \
          Term-ReadLine-Gnu-1.25.tar.gz \
          Term-ShellUI-0.92.tar.gz \
          Term-Size-0.207.tar.gz \
          TermReadKey-2.32.tar.gz \
          Test-Cmd-1.08.tar.gz \
          Test-Simple-1.001014.tar.gz \
          Text-Abbrev-1.02.tar.gz \
          Text-Balanced-2.02.tar.gz \
          Text-ParseWords-3.29.tar.gz \
          Text-Tabs+Wrap-2013.0523.tar.gz \
          Thread-Queue-3.05.tar.gz \
          Thread-Semaphore-2.12.tar.gz \
          Tie-RefHash-1.39.tar.gz \
          Time-HiRes-1.9726.tar.gz \
          Time-Local-1.2300.tar.gz \
          Try-Tiny-0.22.tar.gz \
          Variable-Magic-0.55.tar.gz \
          XML-NamespaceSupport-1.11.tar.gz \
          XML-SAX-Base-1.08.tar.gz \
          YAML-1.14.tar.gz \
          YAML-Tiny-1.67.tar.gz \
          base-2.18.tar.gz \
          libnet-3.05.tar.gz \
          podlators-2.5.3.tar.gz \
          threads-2.01.tar.gz \
          threads-shared-1.46.tar.gz \
          Archive-Tar-2.04.tar.gz \
          Archive-Zip-1.43.tar.gz \
          Attribute-Handlers-0.96.tar.gz \
          Bit-Vector-7.4.tar.gz \
          CPAN-Meta-YAML-0.012.tar.gz \
          DBD-mysql-4.031.tar.gz \
          Date-Calc-6.4.tar.gz \
          Date-Calc-XS-6.4.tar.gz \
          Encode-2.68.tar.gz \
          ExtUtils-Helpers-0.022.tar.gz \
          File-Listing-6.04.tar.gz \
          File-ShareDir-1.102.tar.gz \
          Gearman-1.12.tar.gz \
          HTML-Parser-3.71.tar.gz \
          Module-Metadata-1.000027.tar.gz \
          Module-ScanDeps-1.18.tar.gz \
          Parse-CPAN-Meta-1.4414.tar.gz \
          Term-Clui-1.70.tar.gz \
          URI-1.67.tar.gz \
          WWW-RobotRules-6.02.tar.gz \
          XML-SAX-0.99.tar.gz \
          XML-Simple-2.20.tar.gz \
          autodie-2.26.tar.gz \
          Class-MethodMaker-2.22.tar.gz \
          HTML-Lint-2.20.tar.gz \
          HTTP-Message-6.06.tar.gz \
          HTTP-Negotiate-6.01.tar.gz \
          Module-Load-Conditional-0.64.tar.gz \
          Monitoring-Livestatus-0.74.tar.gz \
          Net-HTTP-6.07.tar.gz \
          Term-ProgressBar-2.17.tar.gz \
          XML-LibXML-2.0117.tar.gz \
          HTTP-Body-1.22.tar.gz \
          HTTP-Cookies-6.01.tar.gz \
          HTTP-Daemon-6.01.tar.gz \
          IPC-Cmd-0.92.tar.gz \
          List-MoreUtils-0.410.tar.gz \
          Plack-1.0034.tar.gz \
          libwww-perl-6.13.tar.gz \
          ExtUtils-CBuilder-0.280220.tar.gz \
          ExtUtils-ParseXS-3.24.tar.gz \
          IO-1.25.tar.gz \
          LWP-Protocol-https-6.06.tar.gz \
          List-AllUtils-0.09.tar.gz \
          Module-Build-0.4007.tar.gz \
          Module-Install-1.16.tar.gz \
          Module-Runtime-0.014.tar.gz \
          Params-Util-1.07.tar.gz \
          Parse-RecDescent-1.967009.tar.gz \
          Path-Class-0.35.tar.gz \
          Readonly-2.00.tar.gz \
          Socket-2.019.tar.gz \
          Spreadsheet-WriteExcel-2.40.tar.gz \
          Tie-IxHash-1.23.tar.gz \
          XML-Parser-2.44.tar.gz \
          XML-Twig-3.48.tar.gz \
          constant-1.27.tar.gz \
          App-cpanminus-1.7024.tar.gz \
          CPAN-2.05.tar.gz \
          Config-Tiny-2.20.tgz \
          Crypt-SSLeay-0.72.tar.gz \
          Date-Manip-6.49.tar.gz \
          Devel-GlobalDestruction-XS-0.01.tar.gz \
          Dist-CheckConflicts-0.11.tar.gz \
          Error-0.17022.tar.gz \
          Excel-Template-0.34.tar.gz \
          File-BOM-0.14.tar.gz \
          File-SearchPath-0.06.tar.gz \
          HTML-Escape-1.09.tar.gz \
          LWP-Protocol-connect-6.09.tar.gz \
          Module-Implementation-0.09.tar.gz \
          Package-Stash-0.37.tar.gz \
          Params-Validate-1.18.tar.gz \
          B-Hooks-EndOfScope-0.13.tar.gz \
          DateTime-Locale-0.45.tar.gz \
          DateTime-TimeZone-1.88.tar.gz \
          Devel-GlobalDestruction-0.13.tar.gz \
          Log-Dispatch-2.44.tar.gz \
          Monitoring-Plugin-0.38.tar.gz \
          Nagios-Plugin-0.36.tar.gz \
          namespace-clean-0.25.tar.gz \
          DateTime-1.18.tar.gz




build:
	mkdir -p $(P5TMPDIST)/dest
	rm -rf $(P5TMPDIST)/src
	ln -s ../src $(P5TMPDIST)/src
	echo "install --install_base $(P5TMPDIST)/dest" > $(P5TMPDIST)/dest/.modulebuildrc
	unset LANG; \
	unset PERL5LIB; \
	unset PERL_MB_OPT; \
	unset PERL_LOCAL_LIB_ROOT; \
	unset PERL_MM_OPT; \
	export PATH=$(P5TMPDIST)/dest/bin:$$PATH; \
	    export PERL_MM_OPT=INSTALL_BASE=$(P5TMPDIST)/dest; \
	    export PERL_MB_OPT=--install_base=$(P5TMPDIST)/dest; \
	    export MODULEBUILDRC=$(P5TMPDIST)/dest/.modulebuildrc; \
	    export PERL5LIB=$(P5TMPDIST)/dest/lib/perl5:$(P5TMPDIST)/src/lib; \
	    cd $(P5TMPDIST)/src && \
	        FORCE=1 ./build_module.pl -d "$(DISTRO)" -p $(P5TMPDIST)/dest \
	            ExtUtils-MakeMaker-*.tar.gz \
	            parent-*.tar.gz \
	            version-*.tar.gz \
	            Module-CoreList-*.tar.gz \
	            common-sense-*.tar.gz \
	            Types-Serialiser-*.tar.gz \
	            JSON-*.tar.gz; \
	    export PERL_JSON_BACKEND='JSON::XS'; \
	    cd $(P5TMPDIST)/src && \
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
