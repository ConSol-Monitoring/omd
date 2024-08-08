include ../../Makefile.omd

NAME = omd
VERSION = $(OMD_VERSION)
SHELL = /bin/bash

.PHONY: skel

build:

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 omd $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 monitoring_core $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 merge-core-config $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 create_site_selfsigned_cert $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 set_admin_password $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 sleep_while_omd_running $(DESTDIR)$(OMD_ROOT)/bin
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/omd/htdocs
	install -m 644 index.html $(DESTDIR)$(OMD_ROOT)/share/omd/htdocs
	install -m 644 logout.php $(DESTDIR)$(OMD_ROOT)/share/omd/htdocs
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/omd/htdocs/img
	install -m 644 img/* $(DESTDIR)$(OMD_ROOT)/share/omd/htdocs/img
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/man/man8
	install -m 644 omd.8 $(DESTDIR)$(OMD_ROOT)/share/man/man8
	gzip $(DESTDIR)$(OMD_ROOT)/share/man/man8/omd.8
	install -m 644 omd.service $(DESTDIR)$(OMD_ROOT)/share/omd/omd.service
	# TasksMax has been introduced with systemd 226
	if test -x /usr/bin/systemctl && [ $$(systemctl --version | head -n1 | awk {'print $$2'}) -ge 226 ]; then \
		sed -i $(DESTDIR)$(OMD_ROOT)/share/omd/omd.service -e 's/^#TasksMax=/TasksMax=/g'; \
	fi
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/doc/$(NAME)
	install -m 644 COPYING AUTHORS $(DESTDIR)$(OMD_ROOT)/share/doc/$(NAME)
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/omd
	install -m 644 init_profile $(DESTDIR)$(OMD_ROOT)/lib/omd/
	install -m 755 port_is_used $(DESTDIR)$(OMD_ROOT)/lib/omd/
	install -m 644 omd_bash_completion $(DESTDIR)$(OMD_ROOT)/lib/omd/
	install -m 600 openssl.cnf $(DESTDIR)$(OMD_ROOT)/share/omd/
	
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/omd/scripts/post-create
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/omd/scripts/pre-update
	install -m 755 omd.pre-update $(DESTDIR)$(OMD_ROOT)/lib/omd/scripts/pre-update/omd
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/omd/scripts/diag
	rsync -a diag-scripts/. $(DESTDIR)$(OMD_ROOT)/lib/omd/scripts/diag/.
	chmod 755 $(DESTDIR)$(OMD_ROOT)/lib/omd/scripts/diag/*

skel:
	install -m 644 gitignore $(SKEL)/.gitignore
	mkdir -p $(SKEL)/etc/bash_completion.d
	install -m 644 omd_bash_completion $(SKEL)/etc/bash_completion.d

clean:
