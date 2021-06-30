include ../../Makefile.omd

NAME     = perl-modules
VERSION  = $(OMD_VERSION)
DISTRO   = $(shell ../../distro)

SYBASE   = $(shell readlink -m ../freetds/tmpinstall$(OMD_ROOT))

MODULES = \
          App-cpanminus-1.7043.tar.gz \
          AppConfig-1.71.tar.gz \
          Capture-Tiny-0.46.tar.gz \
          Carp-Clan-6.06.tar.gz \
          Class-Accessor-0.51.tar.gz \
          Class-Inspector-1.32.tar.gz \
          Class-Singleton-1.5.tar.gz \
          Clone-0.39.tar.gz \
          Compress-Raw-Bzip2-2.101.tar.gz \
          Compress-Raw-Zlib-2.101.tar.gz \
          Config-General-2.63.tar.gz \
          Config-Tiny-2.23.tgz \
          Crypt-Blowfish_PP-1.12.tar.gz \
          Crypt-DES-2.07.tar.gz \
          Crypt-RC4-2.02.tar.gz \
          Crypt-Rijndael-1.14.tar.gz \
          DBI-1.639.tar.gz \
          DBD-Sybase-1.16.tar.gz \
          DBD-SQLite-1.66.tar.gz \
          Data-Dumper-2.161.tar.gz \
          Date-Manip-6.60.tar.gz \
          Devel-GlobalDestruction-XS-0.03.tar.gz \
          Digest-1.17.tar.gz \
          Digest-HMAC-1.03.tar.gz \
          Digest-MD5-2.55.tar.gz \
          Digest-Perl-MD5-1.9.tar.gz \
          Digest-SHA-6.02.tar.gz \
          Digest-SHA1-2.13.tar.gz \
          Email-Address-1.908.tar.gz \
          Email-Date-Format-1.005.tar.gz \
          Email-MIME-ContentType-1.022.tar.gz \
          Email-MIME-Encodings-1.315.tar.gz \
          Email-MessageID-1.406.tar.gz \
          Email-Simple-2.214.tar.gz \
          Encode-Locale-1.05.tar.gz \
          Exporter-5.72.tar.gz \
          Exporter-Tiny-1.000000.tar.gz \
          ExtUtils-Config-0.008.tar.gz \
          ExtUtils-Constant-0.24.tar.gz \
          ExtUtils-Helpers-0.026.tar.gz \
          ExtUtils-InstallPaths-0.011.tar.gz \
          ExtUtils-Manifest-1.70.tar.gz \
          FCGI-0.78.tar.gz \
          File-Copy-Recursive-0.40.tar.gz \
          File-Path-2.15.tar.gz \
          File-Remove-1.57.tar.gz \
          File-Slurp-9999.27.tar.gz \
          GD-2.50.tar.gz \
          Getopt-Long-2.50.tar.gz \
          HTML-Tagset-3.20.tar.gz \
          HTTP-Date-6.02.tar.gz \
          HTTP-MultiPartParser-0.02.tar.gz \
          Hash-MultiValue-0.16.tar.gz \
          IO-Compress-2.074.tar.gz \
          IO-String-1.08.tar.gz \
          IO-Zlib-1.10.tar.gz \
          IO-stringy-2.111.tar.gz \
          LWP-MediaTypes-6.02.tar.gz \
          List-MoreUtils-0.428.tar.gz \
          Locale-Maketext-Simple-0.21.tar.gz \
          Log-Log4perl-1.49.tar.gz \
          MIME-Base64-3.15.tar.gz \
          MIME-Lite-3.030.tar.gz \
          MIME-Types-2.16.tar.gz \
          Math-Calc-Units-1.07.tar.gz \
          Math-Complex-1.59.tar.gz \
          Module-Find-0.13.tar.gz \
          Module-Load-0.32.tar.gz \
          Mozilla-CA-20160104.tar.gz \
          OLE-Storage_Lite-0.19.tar.gz \
          Package-Stash-XS-0.28.tar.gz \
          Params-Check-0.38.tar.gz \
          PathTools-3.62.tar.gz \
          Perl-OSType-1.010.tar.gz \
          Pod-Escapes-1.07.tar.gz \
          Pod-Simple-3.35.tar.gz \
          Pod-Usage-1.69.tar.gz \
          Scalar-List-Utils-1.49.tar.gz \
          Spreadsheet-ParseExcel-0.65.tar.gz \
          Stream-Buffered-0.03.tar.gz \
          String-CRC32-1.6.tar.gz \
          Sub-Exporter-Progressive-0.001013.tar.gz \
          Sub-Identify-0.14.tar.gz \
          Sub-Install-0.928.tar.gz \
          Sub-Name-0.21.tar.gz \
          Sys-SigAction-0.23.tar.gz \
          Template-Toolkit-2.27.tar.gz \
          Term-ReadLine-Gnu-1.35.tar.gz \
          Term-ShellUI-0.92.tar.gz \
          Term-Size-0.207.tar.gz \
          TermReadKey-2.37.tar.gz \
          Test-Cmd-1.09.tar.gz \
          Test-Simple-1.302120.tar.gz \
          Text-Abbrev-1.02.tar.gz \
          Text-Balanced-2.03.tar.gz \
          Text-Template-1.55.tar.gz \
          Text-ParseWords-3.30.tar.gz \
          Text-Tabs+Wrap-2013.0523.tar.gz \
          Thread-Queue-3.13.tar.gz \
          Thread-Semaphore-2.13.tar.gz \
          Tie-RefHash-1.39.tar.gz \
          Time-Duration-1.20.tar.gz \
          TimeDate-2.30.tar.gz \
          Time-HiRes-1.9753.tar.gz \
          Try-Tiny-0.30.tar.gz \
          Variable-Magic-0.62.tar.gz \
          XML-NamespaceSupport-1.12.tar.gz \
          XML-SAX-Base-1.09.tar.gz \
          YAML-1.24.tar.gz \
          YAML-Tiny-1.70.tar.gz \
          base-2.23.tar.gz \
          constant-1.33.tar.gz \
          libnet-3.11.tar.gz \
          podlators-4.10.tar.gz \
          threads-2.21.tar.gz \
          threads-shared-1.58.tar.gz \
          Archive-Tar-2.26.tar.gz \
          Archive-Zip-1.60.tar.gz \
          Attribute-Handlers-0.99.tar.gz \
          Bit-Vector-7.4.tar.gz \
          CPAN-Meta-2.150010.tar.gz \
          CPAN-Meta-YAML-0.018.tar.gz \
          Devel-CheckLib-1.13.tar.gz \
          DBD-mysql-4.050.tar.gz \
          Date-Calc-6.4.tar.gz \
          Date-Calc-XS-6.4.tar.gz \
          Devel-GlobalDestruction-0.14.tar.gz \
          Encode-2.94.tar.gz \
          File-Listing-6.04.tar.gz \
          HTML-Parser-3.72.tar.gz \
          Module-Metadata-1.000033.tar.gz \
          Module-ScanDeps-1.24.tar.gz \
          Term-Clui-1.71.tar.gz \
          Time-Local-1.25.tar.gz \
          URI-1.73.tar.gz \
          WWW-RobotRules-6.02.tar.gz \
          XML-SAX-0.99.tar.gz \
          XML-Simple-2.24.tar.gz \
          autodie-2.29.tar.gz \
          HTML-Lint-2.30.tar.gz \
          HTTP-Message-6.14.tar.gz \
          HTTP-Negotiate-6.01.tar.gz \
          Module-Load-Conditional-0.68.tar.gz \
          Monitoring-Livestatus-0.78.tar.gz \
          Net-HTTP-6.17.tar.gz \
          XML-LibXML-2.0132.tar.gz \
          HTTP-Body-1.22.tar.gz \
          HTTP-Cookies-6.04.tar.gz \
          HTTP-Daemon-6.01.tar.gz \
          IPC-Cmd-0.98.tar.gz \
          libwww-perl-6.31.tar.gz \
          ExtUtils-CBuilder-0.280230.tar.gz \
          ExtUtils-ParseXS-3.35.tar.gz \
          IO-1.25.tar.gz \
          LWP-Protocol-https-6.07.tar.gz \
          Module-Build-0.4007.tar.gz \
          Module-Build-Tiny-0.039.tar.gz \
          Module-Install-1.19.tar.gz \
          Module-Runtime-0.016.tar.gz \
          Params-Util-1.07.tar.gz \
          Parse-RecDescent-1.967015.tar.gz \
          Path-Class-0.37.tar.gz \
          Readonly-2.05.tar.gz \
          Socket-2.027.tar.gz \
          Spreadsheet-WriteExcel-2.40.tar.gz \
          Tie-IxHash-1.23.tar.gz \
          WWW-Form-UrlEncoded-0.24.tar.gz \
          XML-Parser-2.44.tar.gz \
          XML-Twig-3.52.tar.gz \
          CPAN-2.16.tar.gz \
          Cookie-Baker-0.11.tar.gz \
          Dist-CheckConflicts-0.11.tar.gz \
          Email-MIME-1.946.tar.gz \
          Error-0.17025.tar.gz \
          Excel-Template-0.34.tar.gz \
          File-BOM-0.14.tar.gz \
          File-SearchPath-0.07.tar.gz \
          File-ShareDir-Install-0.11.tar.gz \
          HTML-Escape-1.10.tar.gz \
          HTTP-Entity-Parser-0.20.tar.gz \
          HTTP-Headers-Fast-0.21.tar.gz \
          IO-Socket-IP-0.39.tar.gz \
          LWP-Protocol-connect-6.09.tar.gz \
          Module-Implementation-0.09.tar.gz \
          Net-IMAP-Simple-1.2209.tar.gz \
          Package-Stash-0.37.tar.gz \
          Params-Validate-1.29.tar.gz \
          B-Hooks-EndOfScope-0.21.tar.gz \
          File-ShareDir-1.104.tar.gz \
          Gearman-2.004.015.tar.gz \
          List-SomeUtils-0.56.tar.gz \
          Log-Dispatch-2.44.tar.gz \
          Monitoring-Plugin-0.40.tar.gz \
          Nagios-Plugin-0.36.tar.gz \
          Plack-1.0047.tar.gz \
          namespace-clean-0.27.tar.gz \
          List-UtilsBy-0.10.tar.gz \
          List-AllUtils-0.14.tar.gz \
          namespace-autoclean-0.28.tar.gz \
          DateTime-Locale-0.45.tar.gz \
          DateTime-TimeZone-1.88.tar.gz \
          DateTime-1.18.tar.gz \
          File-Tail-1.3.tar.gz \
          UUID-0.28.tar.gz \
          Thruk-Utils-XS-0.02.tar.gz \
          Monitoring-GLPlugin-3.4.1.tar.gz




build:
	mkdir -p $(P5TMPDIST)/dest
	mkdir -p $(P5TMPDIST)/src
	rsync -a src/. $(P5TMPDIST)/src/.
	rsync -a build_module.pl lib patches $(P5TMPDIST)/src/.
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
	    export SYBASE=$(SYBASE); \
	    cd $(P5TMPDIST)/src && \
	        FORCE=1 ./build_module.pl -d "$(DISTRO)" -p $(P5TMPDIST)/dest \
	            ExtUtils-MakeMaker-*.tar.gz \
	            parent-*.tar.gz \
	            version-*.tar.gz \
	            Module-CoreList-*.tar.gz \
	            common-sense-*.tar.gz \
	            Types-Serialiser-*.tar.gz \
	            JSON-*.tar.gz \
	            Cpanel-JSON-*.tar.gz; \
	    export PERL_JSON_BACKEND='Cpanel::JSON::XS'; \
	    cd $(P5TMPDIST)/src && \
	        ./build_module.pl -d "$(DISTRO)" -p $(P5TMPDIST)/dest $(MODULES)
	cd $(P5TMPDIST)/dest/lib/perl5/ && rm -f utils.pm && ln -s ../../../monitoring-plugins/utils.pm .
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
