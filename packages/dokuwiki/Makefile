include ../../Makefile.omd

NAME = dokuwiki
VERSION = 2012-01-25b
DIR = $(NAME)-2012-01-25b

.PHONY: skel

build:
	tar xzf $(NAME)-$(VERSION).tgz
	tar xzf template-arctic-stable.tgz -C $(DIR)/lib/tpl/
	tar xzf template-vector.tar.gz -C $(DIR)/lib/tpl/
	tar xzf plugin-include.tgz -C $(DIR)/lib/plugins/
	tar xf formular.tar -C $(DIR)/lib/plugins/

	for p in patches/*.patch ; do \
		echo "applying $$p..." ; \
		( cd $(DIR) ; patch -p1 -b ) < $$p ; \
	done

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/dokuwiki
	cp preload.php $(DIR)/inc/
	cp multisite.class.php $(DIR)/inc/auth/
	touch $(DIR)/lib/plugins/plugin/disabled
	touch $(DIR)/conf $(DIR)/data
	rm -r $(DIR)/conf $(DIR)/data
	cp -r $(DIR) $(DESTDIR)$(OMD_ROOT)/share/dokuwiki/htdocs
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/doc/dokuwiki
	install -m 644 $(DIR)/README $(DESTDIR)$(OMD_ROOT)/share/doc/dokuwiki
	install -m 644 $(DIR)/COPYING $(DESTDIR)$(OMD_ROOT)/share/doc/dokuwiki
	install -m 644 $(DIR)/VERSION $(DESTDIR)$(OMD_ROOT)/share/doc/dokuwiki

clean:
	# Remove files created by build/install
	rm -rf $(DIR)
