include ../../Makefile.omd

NAME     = Thruk
VERSION  = 2.02
DIR      = $(NAME)-$(VERSION)
PERLARCH = $(shell $(PERL) -e 'use Config; print $$Config{archname}')

.PHONY: skel

build:
	rm -rf $(DIR)
	tar xzf $(DIR)*.tar.gz
	for p in patches/*.patch ; do \
	    echo "applying $$p..." ; \
	    ( cd $(DIR) ; patch -p1 ) < $$p || exit 1; \
	done
	find $(DIR) -name \*.orig -exec rm {} \;


install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/thruk
	cp -rp $(DIR)/script/thruk $(DESTDIR)$(OMD_ROOT)/bin/thruk
	cp -rp $(DIR)/script/naglint $(DESTDIR)$(OMD_ROOT)/bin/naglint
	cp -rp $(DIR) $(DESTDIR)$(OMD_ROOT)/share/thruk
	mkdir -p $(DESTDIR)$(OMD_ROOT)/skel/etc/thruk
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/thruk/plugins-enabled
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/thruk/themes-enabled
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/thruk/t
	mv $(DESTDIR)$(OMD_ROOT)/share/thruk/script/thruk $(DESTDIR)$(OMD_ROOT)/bin/thruk
	chmod 755 $(DESTDIR)$(OMD_ROOT)/bin/thruk
	chmod 755 $(DESTDIR)$(OMD_ROOT)/bin/naglint
	if [ `uname -m` = 'x86_64' ]; then \
		cp -p wkhtmltopdf-amd64 $(DESTDIR)$(OMD_ROOT)/bin/wkhtmltopdf; \
	else \
		cp -p wkhtmltopdf-i386  $(DESTDIR)$(OMD_ROOT)/bin/wkhtmltopdf; \
	fi
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/omd/scripts/post-update
	install -m 755 thruk.post-update $(DESTDIR)$(OMD_ROOT)/lib/omd/scripts/post-update/thruk


skel:
	# logfile has to be group writeable for shared apache
	mkdir -p $(SKEL)/var/log $(SKEL)/var/thruk $(SKEL)/etc/init.d
	touch $(SKEL)/var/log/thruk.log
	mkdir -p $(SKEL)/etc/thruk/plugins-enabled
	# set links for enabled plugins
	for link in `ls -1 $(DIR)/plugins/plugins-enabled/`; do cd $(SKEL)/etc/thruk/plugins-enabled && ln -sfn ../../../share/thruk/plugins/plugins-available/$$link $$link; done
	# set links for enabled themes
	mkdir -p $(SKEL)/etc/thruk/themes-enabled
	for link in `ls -1 $(DIR)/themes/themes-enabled/`; do cd $(SKEL)/etc/thruk/themes-enabled && ln -sfn ../../../share/thruk/themes/themes-available/$$link $$link; done
	cp $(DIR)/support/thruk.init $(SKEL)/etc/init.d/thruk
	mkdir -p $(SKEL)/etc/nagios/conf.d
	cp $(DIR)/support/thruk_templates.cfg $(SKEL)/etc/nagios/conf.d/
	cp $(DIR)/support/fcgid_env.sh $(SKEL)/etc/thruk/fcgid_env.sh
	cp $(DIR)/thruk.conf $(SKEL)/etc/thruk/thruk.conf
	cp -rp $(DIR)/root/thruk/usercontent $(SKEL)/etc/thruk
	for p in patches/*.skel_patch ; do \
	    echo "applying $$p..." ; \
	    ( cd $(SKEL) ; patch -p1 -b ) < $$p || exit 1; \
	done
	find $(SKEL) -name \*.orig -exec rm {} \;
	mkdir -p $(SKEL)/etc/thruk/bp/
	cp $(DIR)/examples/bp_functions.pm $(SKEL)/etc/thruk/bp/
	cp $(DIR)/ssi/status-header.ssi-pnp $(SKEL)/etc/thruk/ssi/status-header.ssi
	cp $(DIR)/ssi/status-header.ssi-pnp $(SKEL)/etc/thruk/ssi/extinfo-header.ssi
	cp $(DIR)/ssi/extinfo-header.ssi-tickets $(SKEL)/etc/thruk/ssi/extinfo-header.ssi-example

clean:
	rm -rf $(DIR)
