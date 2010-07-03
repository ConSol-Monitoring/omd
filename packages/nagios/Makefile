include ../../Makefile.omd

NAME = nagios
VERSION = 3.2.1
DIR = $(NAME)-$(VERSION)

# Configure options for Nagios. Since we want to compile
# as non-root, we use our own user and group for compiling.
# All files will be packaged as user 'root' later anyway.
CONFIGUREOPTS = \
    --sbindir=$(OMD_ROOT)/lib/nagios/cgi-bin \
    --bindir=$(OMD_ROOT)/bin \
    --datarootdir=$(OMD_ROOT)/share/nagios/htdocs \
    --with-nagios-user=$$(id -un) \
    --with-nagios-group=$$(id -gn) \

build: prepare
	for p in patches/*.dif ; do \
	    echo "applying $$p..." ; \
	    ( cd $(DIR) ; patch -p1 -b ) < $$p ; \
	done
	cd $(DIR) ; ./configure $(CONFIGUREOPTS)
	$(MAKE) -C $(DIR) all

prepare:
	tar xzf $(DIR).tar.gz

install:
	$(MAKE) DESTDIR=$(DESTDIR) -C $(DIR) install-base install-cgis install-html
	rm -f $(DESTDIR)$(OMD_ROOT)/share/nagios/htdocs/config.php.inc

skel:

clean:
	rm -rf $(DIR)
