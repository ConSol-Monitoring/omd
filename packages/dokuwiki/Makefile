include ../../Makefile.omd

NAME = dokuwiki
VERSION = 2017-02-19e
DIR = $(NAME)

.PHONY: skel

build:
	tar xzf $(NAME)-$(VERSION).tgz
	tar xzf template-arctictut.tgz -C $(DIR)/lib/tpl/
	ln -sf ../../../images/fileicons/pdf.png $(DIR)/lib/tpl/arctictut/images/tool-pdf.png
	tar xzf template-vector.tgz -C $(DIR)/lib/tpl/

	for p in plugins/*.tgz ; do \
		echo "add plugin $$p..." ; \
		tar xzf $$p -C $(DIR)/lib/plugins ; \
	done

	for p in patches/*.patch ; do \
		echo "applying $$p..." ; \
		( cd $(DIR) ; patch -p1 -b ) < $$p ; \
	done
	find $(DIR)/ -name \*.orig -exec rm {} \;
	find $(DIR)/ -name ._\* -exec rm {} \;

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/dokuwiki
	cp preload.php $(DIR)/inc/
	cp -r authmultisite $(DIR)/lib/plugins/
	cp -r $(DIR) $(DESTDIR)$(OMD_ROOT)/share/dokuwiki/htdocs
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/doc/dokuwiki
	install -m 644 $(DIR)/README $(DESTDIR)$(OMD_ROOT)/share/doc/dokuwiki
	install -m 644 $(DIR)/COPYING $(DESTDIR)$(OMD_ROOT)/share/doc/dokuwiki
	install -m 644 $(DIR)/VERSION $(DESTDIR)$(OMD_ROOT)/share/doc/dokuwiki
	# remove the biggest 4 fonts
	rm -f $(DESTDIR)$(OMD_ROOT)/share/dokuwiki/htdocs/lib/plugins/dw2pdf/vendor/mpdf/mpdf/ttfonts/Aegyptus.otf
	rm -f $(DESTDIR)$(OMD_ROOT)/share/dokuwiki/htdocs/lib/plugins/dw2pdf/vendor/mpdf/mpdf/ttfonts/UnBatang_0613.ttf
	rm -f $(DESTDIR)$(OMD_ROOT)/share/dokuwiki/htdocs/lib/plugins/dw2pdf/vendor/mpdf/mpdf/ttfonts/Sun-ExtB.ttf
	rm -f $(DESTDIR)$(OMD_ROOT)/share/dokuwiki/htdocs/lib/plugins/dw2pdf/vendor/mpdf/mpdf/ttfonts/Sun-ExtA.ttf

skel:
	mkdir -p $(SKEL)/etc/dokuwiki
	mkdir -p $(SKEL)/var/dokuwiki/lib/plugins
	cp $(DIR)/conf/*.conf				$(SKEL)/etc/dokuwiki/.
	cp $(DIR)/conf/*.php$				$(SKEL)/etc/dokuwiki/.
	cp $(DIR)/conf/acl.auth.php.dist	$(SKEL)/etc/dokuwiki/acl.auth.php
	cp $(DIR)/conf/mysql.conf.php.example $(SKEL)/etc/dokuwiki/mysql.conf.php.example

	for p in patches/*.skel_patch ; do \
	    echo "applying $$p..." ; \
	    ( cd $(SKEL) ; patch -p1 ) < $$p || exit 1; \
	done

	cd $(SKEL)/var/dokuwiki/lib/plugins/ ; \
	for i in `ls -1 $(DESTDIR)$(OMD_ROOT)/share/dokuwiki/htdocs/lib/plugins/` ; do \
	    ln -s ../../../../share/dokuwiki/htdocs/lib/plugins/$$i . ; \
	done

clean:
	# Remove files created by build/install
	rm -rf $(DIR)
