include ../../Makefile.omd

NAME = perl-modules
VERSION = 0.42
DESTDIR = $(OMD_ROOT)

build: local-lib

install: build

skel:

clean:
	if [ -d $(DESTDIR)/lib/perl5 ]; then rm -r $(DESTDIR)/lib/perl5; fi
	if [ -d src/local-lib-1.006005 ]; then rm -r src/local-lib-1.006005; fi

local-lib: init-cpan
	module="src/local-lib-1.006005.tar.gz"; \
	if [ ! -d $(DESTDIR)/lib/perl5 ]; then \
	    cd src; \
	    echo `basename $$module`; \
	    tarfile=`basename $$module`; \
	    tar zxf "$$tarfile"; \
	    dir=`echo $$tarfile | sed s/\.tar\.gz//`; \
	    cd $$dir; \
	    ../../defaults /usr/bin/perl Makefile.PL --bootstrap=$(DESTDIR)/lib/perl5 || exit 1; \
	    make; \
	    make install;  \
	    cd ../..; \
	fi

init-cpan:
