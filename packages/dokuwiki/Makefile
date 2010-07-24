include ../../Makefile.omd

NAME = dokuwiki
VERSION = 2009-12-25c
DIR = $(NAME)-2009-12-25

build:
	tar xzf  $(NAME)-$(VERSION).tgz

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/dokuwiki
	cp preload.php $(DIR)/inc/
	touch $(DIR)/lib/plugins/plugin/disabled
	cp -r $(DIR) $(DESTDIR)$(OMD_ROOT)/share/dokuwiki/htdocs

skel:
	# Optional target called to create additional files below skel

clean:
	# Remove files created by build/install
