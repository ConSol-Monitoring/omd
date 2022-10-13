include ../../Makefile.omd

NAME = shellinabox
VERSION = 2.21
DIR = $(NAME)-$(VERSION)
SRC = $(DIR).tar.gz

CONFIGUREOPTS = LIBS="-lssl -lcrypto"

.PHONY: skel

skel:

build: clean
	tar xzf $(SRC)
	for p in patches/*.patch ; do \
		echo "applying $$p..." ; \
		( cd $(NAME) ; patch -p1 ) < $$p || exit 1; \
	done
	cd $(NAME) && autoreconf -i && ./configure $(CONFIGUREOPTS) && $(MAKE)

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(NAME)/shellinaboxd  $(DESTDIR)$(OMD_ROOT)/bin
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/shellinabox
	rsync -a share/ $(DESTDIR)$(OMD_ROOT)/share/shellinabox/

package:
	git clone --depth=1 --branch "master" https://github.com/shellinabox/shellinabox.git
	tar cfz $(SRC) --exclude=.git shellinabox
	rm -rf shellinabox

clean:
	rm -rf $(DIR)
	rm -rf $(NAME)
