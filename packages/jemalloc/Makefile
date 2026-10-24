include ../../Makefile.omd

NAME    = jemalloc
VERSION = 5.3.0
DIR     = $(NAME)-$(VERSION)

CONFIGUREOPTS = \
    --prefix=$(OMD_ROOT) \
    --libdir=$(OMD_ROOT)/lib \
    --disable-debug

build:
	tar xfJ $(NAME)-$(VERSION).tar.xz
	cd $(DIR) && CFLAGS="$(CFLAGS)" ./configure $(CONFIGUREOPTS)
	$(MAKE) -C $(DIR) all
	# jemalloc's makefile skips ranlib (GNU make treats libtool as indexer),
	# leaving libjemalloc.a without a symbol table on older binutils
	ranlib $(DIR)/lib/libjemalloc.a

# jemalloc is a build-only dependency: its static library is linked e.g.
# into the naemon binaries at build time (see packages/naemon), so nothing is
# loaded at runtime and nothing must be installed into the package.
install:

skel:

clean:
	rm -rf $(DIR)

upstream:
	rm -f $(NAME)-$(VERSION).tar.xz
	wget "https://github.com/jemalloc/jemalloc/releases/download/$(VERSION)/$(NAME)-$(VERSION).tar.bz2"
	tar xjf $(NAME)-$(VERSION).tar.bz2
	XZ_OPT=-8 tar cfJ $(NAME)-$(VERSION).tar.xz $(DIR)
	rm -rf $(DIR)
	rm -f $(NAME)-$(VERSION).tar.bz2
