include ../../Makefile.omd

NAME    = perl-modules
VERSION = $(OMD_VERSION)
SRC     = $(shell basename src/local-lib-*.gz | sed s/\.tar\.gz// )

build: init-cpan
	cd src; tar zxf $(SRC).tar.gz
	cd src/$(SRC); ../../defaults /usr/bin/perl Makefile.PL --bootstrap=build
	cd src/$(SRC); $(MAKE)
	cd src/$(SRC); $(MAKE) DESTDIR="" install

install:
	if [ -z $(DESTDIR) ]; then echo "cannot install without DESTDIR set!"; exit 1; fi
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib
	mv src/$(SRC)/build $(DESTDIR)$(OMD_ROOT)/lib/perl5

skel:

clean:
	if [ -d src/$(SRC) ]; then rm -rf src/$(SRC); fi

init-cpan:
	./defaults cpan
