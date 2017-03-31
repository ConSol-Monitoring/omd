include ../../Makefile.omd

NAME = mk-livestatus
VERSION = 1.2.8p20
DIR = $(NAME)-$(VERSION)

CONFIGUREOPTS = \
    --prefix=$(OMD_ROOT)

.PHONY: build_env_for_centos6_gmp build_env_for_centos6_mpfr build_env_for_centos6_mpc build_env_for_centos6_gcc build_env_for_centos6

TMPGCC = $(shell pwd)/tmp_gcc
$(info checking special compile settings for distro $(DISTRO_INFO))
ifneq (,$(findstring SLES 11SP4,$(DISTRO_INFO)))
$(info compile with gcc 4.8)
export CC := gcc-4.8
export CXX := g++-4.8
else ifneq (,$(findstring SLES 11SP,$(DISTRO_INFO)))
$(info compile with gcc 4.7)
export CC := gcc-4.7
export CXX := g++-4.7
else ifneq (,$(findstring CENTOS 6,$(DISTRO_INFO)))
$(info compile with gcc 4.7.2 from source)
export PATH := $(TMPGCC)/bin/:$(PATH)
export LD_LIBRARY_PATH := $(TMPGCC)/lib64:$(LD_LIBRARY_PATH)
EXTRA_BUILD_DEPS=build_env_for_centos6
else ifneq (,$(findstring UBUNTU 12.04,$(DISTRO_INFO)))
$(info compile with gcc 4.7.2 from source)
export PATH := $(TMPGCC)/bin/:$(PATH)
export LD_LIBRARY_PATH := $(TMPGCC)/lib64:$(LD_LIBRARY_PATH)
EXTRA_BUILD_DEPS=build_env_for_centos6
endif


build: $(EXTRA_BUILD_DEPS)
	tar xzf $(DIR).tar.gz
	cd $(DIR) ; ./configure $(CONFIGUREOPTS)
	$(MAKE) -C $(DIR) all

install:
	$(MAKE) DESTDIR=$(DESTDIR) -C $(DIR) install
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 lq $(DESTDIR)$(OMD_ROOT)/bin
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/python
	install -m 644 $(DIR)/api/python/livestatus.py $(DESTDIR)$(OMD_ROOT)/lib/python

skel:

clean:
	rm -rf mk-livestatus-*.*.*[0-9]
	rm -rf $(TMPGCC)

upstream:
	if [ ! -e mk-livestatus-$(VERSION).tar.gz ] ; then \
	  git rm mk-livestatus-*.tar.gz || true ; \
	  rm -f mk-livestatus-*.tar.gz ; \
	  wget http://mathias-kettner.de/download/mk-livestatus-$(VERSION).tar.gz ; \
	  git add mk-livestatus-$(VERSION).tar.gz ; \
	fi

build_env_for_centos6_gmp:
#	wget ftp://gcc.gnu.org/pub/gcc/infrastructure/gmp-4.3.2.tar.bz2
	tar xjf gmp-4.3.2.tar.bz2 && \
	cd gmp-4.3.2 && \
	./configure --disable-shared --enable-static --prefix=$(TMPGCC) && \
	make && make check && make install

build_env_for_centos6_mpfr:
#	wget ftp://gcc.gnu.org/pub/gcc/infrastructure/mpfr-2.4.2.tar.bz2
	tar xjf mpfr-2.4.2.tar.bz2
	cd mpfr-2.4.2 && \
	./configure --disable-shared --enable-static --prefix=$(TMPGCC) --with-gmp=$(TMPGCC) && \
	make && make check && make install

build_env_for_centos6_mpc:
#	wget ftp://gcc.gnu.org/pub/gcc/infrastructure/mpc-0.8.1.tar.gz
	tar xzf mpc-0.8.1.tar.gz
	cd mpc-0.8.1 && \
	./configure --disable-shared --enable-static --prefix=$(TMPGCC) --with-gmp=$(TMPGCC) --with-mpfr=$(TMPGCC) && \
	make && make check && make install

build_env_for_centos6_elf:
#	wget http://www.mr511.de/software/libelf-0.8.13.tar.gz
	test -f $(TMPGCC)/lib/libelf.a || \
	tar zxf libelf-0.8.13.tar.gz && \
	cd libelf-0.8.13 && \
	./configure --disable-shared --enable-static --prefix=$(TMPGCC) && \
	make && make check && make install

#	--disable-shared \
build_env_for_centos6_elf_gcc:
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

build_env_for_centos6:
	test -f $(TMPGCC)/lib/libgmp.a || make build_env_for_centos6_gmp
	test -f $(TMPGCC)/lib/libmpfr.a || make build_env_for_centos6_mpfr
	test -f $(TMPGCC)/lib/libmpc.a || make build_env_for_centos6_mpc
	test -f $(TMPGCC)/lib/libelf.a || make build_env_for_centos6_elf
	test -f $(TMPGCC)/bin/gcc || make build_env_for_centos6_gcc
