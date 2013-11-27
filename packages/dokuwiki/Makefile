include ../../Makefile.omd

NAME = dokuwiki
VERSION = 2013-05-10a
DIR = $(NAME)-2013-05-10a

.PHONY: skel

build:
	tar xzf $(NAME)-$(VERSION).tgz
	tar xzf template-arctictut.tgz -C $(DIR)/lib/tpl/
	ln -sf ../../../images/fileicons/pdf.png $(DIR)/lib/tpl/arctictut/images/tool-pdf.png
	tar xzf template-vector.tgz -C $(DIR)/lib/tpl/
	tar xzf plugin-include.tgz -C $(DIR)/lib/plugins/
	tar xzf plugin-dw2pdf.tgz -C $(DIR)/lib/plugins/
	tar xzf plugin-bookcreator.tgz -C $(DIR)/lib/plugins/
	tar xf formular.tar -C $(DIR)/lib/plugins/

	for p in patches/*.patch ; do \
		echo "applying $$p..." ; \
		( cd $(DIR) ; patch -p1 -b ) < $$p ; \
	done

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/dokuwiki
	cp preload.php $(DIR)/inc/
	cp -r authmultisite $(DIR)/lib/plugins/
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
