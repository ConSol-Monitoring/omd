include ../../Makefile.omd

NAME = gcc

.PHONY: build_gmp build_mpfr build_mpc build_elf_gcc build_all

TMPGCC = $(shell pwd)/tmp_gcc
export PATH := $(TMPGCC)/bin/:$(PATH)
export LD_LIBRARY_PATH := $(TMPGCC)/lib64:$(LD_LIBRARY_PATH)

ifneq (,$(findstring CENTOS 6,$(DISTRO_INFO)))
EXTRA_BUILD_DEPS=build_all
else ifneq (,$(findstring SLES 11SP2,$(DISTRO_INFO)))
EXTRA_BUILD_DEPS=build_all
else ifneq (,$(findstring UBUNTU 12.04,$(DISTRO_INFO)))
EXTRA_BUILD_DEPS=build_all
endif

ifdef EXTRA_BUILD_DEPS
EXTRA_INSTALL_DEPS=install_all
endif


build: $(EXTRA_BUILD_DEPS)

install: $(EXTRA_INSTALL_DEPS)

install_all:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib
	cp -p $(TMPGCC)/lib64/libstdc++.* $(DESTDIR)$(OMD_ROOT)/lib

skel:

clean:
	rm -rf $(TMPGCC)
	rm -rf gcc-?.?.?
	rm -rf gmp-?.?.?
	rm -rf libelf-?.?.??
	rm -rf mpc-?.?.?
	rm -rf mpfr-?.?.?

build_gmp:
#	wget ftp://gcc.gnu.org/pub/gcc/infrastructure/gmp-4.3.2.tar.bz2
	tar xjf gmp-4.3.2.tar.bz2 && \
	cd gmp-4.3.2 && \
	./configure --disable-shared --enable-static --prefix=$(TMPGCC) && \
	make && make install

build_mpfr:
#	wget ftp://gcc.gnu.org/pub/gcc/infrastructure/mpfr-2.4.2.tar.bz2
	tar xjf mpfr-2.4.2.tar.bz2
	cd mpfr-2.4.2 && \
	./configure --disable-shared --enable-static --prefix=$(TMPGCC) --with-gmp=$(TMPGCC) && \
	make && make install

build_mpc:
#	wget ftp://gcc.gnu.org/pub/gcc/infrastructure/mpc-0.8.1.tar.gz
	tar xzf mpc-0.8.1.tar.gz
	cd mpc-0.8.1 && \
	./configure --disable-shared --enable-static --prefix=$(TMPGCC) --with-gmp=$(TMPGCC) --with-mpfr=$(TMPGCC) && \
	make && make install

build_elf:
#	wget http://www.mr511.de/software/libelf-0.8.13.tar.gz
	test -f $(TMPGCC)/lib/libelf.a || \
	tar zxf libelf-0.8.13.tar.gz && \
	cd libelf-0.8.13 && \
	./configure --disable-shared --enable-static --prefix=$(TMPGCC) && \
	make && make install

build_elf_gcc:
	test -f $(TMPGCC)/bin/gcc || \
	tar xjf gcc-4.7.4.tar.bz2 && \
	cd gcc-4.7.4 && \
	./configure \
	--prefix=$(TMPGCC) \
	--disable-bootstrap \
	--disable-multilib \
	--enable-languages="c,c++" \
	--enable-libgomp \
	--enable-lto \
	--enable-threads=posix \
	--enable-tls \
	--with-gmp=$(TMPGCC) \
	--with-mpfr=$(TMPGCC) \
	--with-mpc=$(TMPGCC) \
	--with-libelf=$(TMPGCC) \
	--with-fpmath=sse && \
	make && make install \

build_all:
	test -f $(TMPGCC)/lib/libgmp.a || make build_gmp
	test -f $(TMPGCC)/lib/libmpfr.a || make build_mpfr
	test -f $(TMPGCC)/lib/libmpc.a || make build_mpc
	test -f $(TMPGCC)/lib/libelf.a || make build_elf
	test -f $(TMPGCC)/bin/gcc || make build_elf_gcc
