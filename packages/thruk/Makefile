include ../../Makefile.omd

NAME = Thruk
VERSION = 0.72
DIR = $(NAME)-$(VERSION)

build:
	tar xzf $(DIR).tar.gz
	cd $(DIR) ; echo "" | $(PERL) Makefile.PL


install:
	$(MAKE) DESTDIR=$(DESTDIR) -C $(DIR) install

skel:

clean:
	rm -rf $(DIR)
