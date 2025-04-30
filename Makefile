SHELL = /bin/bash
# You can select a subset of the packages by overriding this
# variale, e.g. make PACKAGES='nagios rrdtool' pack
PACKAGES =
PACKAGES += freetds
PACKAGES += perl-modules
PACKAGES += go-1.4
PACKAGES += go-1.19
PACKAGES += go-1.21
PACKAGES += go-1.22
PACKAGES += go-1.23
PACKAGES += go-1.24
PACKAGES += upx
PACKAGES += node
PACKAGES += node-modules
PACKAGES += influxdb
PACKAGES += nagflux
PACKAGES += python-modules
PACKAGES += apache-omd
PACKAGES += check_multi
PACKAGES += dokuwiki
PACKAGES += example
PACKAGES += jmx4perl
PACKAGES += mysql-omd
PACKAGES += icinga2
PACKAGES += naemon
PACKAGES += naemon-livestatus
PACKAGES += naemon-plugins
PACKAGES += logos
PACKAGES += nrpe
PACKAGES += nsca
PACKAGES += omd
PACKAGES += monitoring-plugins
PACKAGES += check_plugins
PACKAGES += pnp4nagios
PACKAGES += pnp4nagios4
PACKAGES += rrdtool
PACKAGES += thruk
PACKAGES += thruk-plugins
PACKAGES += thruk-consol-theme
PACKAGES += grafana
PACKAGES += grafana-loki
PACKAGES += histou
PACKAGES += maintenance
PACKAGES += gearmand
PACKAGES += mod-gearman
PACKAGES += mod-gearman-worker-go
PACKAGES += patch
PACKAGES += nail
PACKAGES += notifications-tt
PACKAGES += ansible
PACKAGES += coshsh
PACKAGES += lmd
PACKAGES += prometheus
PACKAGES += prometheus_snmp_exporter
PACKAGES += prometheus_node_exporter
PACKAGES += prometheus_alertmanager
PACKAGES += prometheus_blackbox_exporter
PACKAGES += prometheus_pushgateway
PACKAGES += promlens
PACKAGES += promxy
PACKAGES += telegraf
PACKAGES += snmptrapd
PACKAGES += downtime-api
PACKAGES += dacretain
PACKAGES += grafana-pnp-datasource
PACKAGES += grafana-thruk-datasource
PACKAGES += sakuli
PACKAGES += victoriametrics
PACKAGES += xinetd
PACKAGES += shellinabox

include Makefile.omd

# This file may override the list of packages
-include .config

DESTDIR ?=$(shell pwd)/destdir
RPM_TOPDIR=$(shell pwd)/rpm.topdir
SOURCE_NAME=omd-$(OMD_VERSION)
SOURCE_TGZ=$(SOURCE_NAME).tar.gz
BIN_TGZ=$(SOURCE_NAME)-bin.tar.gz
NEWSERIAL=$$(($(OMD_SERIAL) + 1))
APACHE_NAME=$(APACHE_INIT_NAME)
ifdef BUILD_CACHE
DEFAULT_BUILD=build-cached
else
DEFAULT_BUILD=build
endif

.PHONY: install-global Changelog release_notes_blog.md build

omd: $(DEFAULT_BUILD)

build-cached:
	@set -e ; cd packages ; for p in $(PACKAGES) ; do \
	    NOW=$$(date +%s); \
	    OMD_ROOT="$(OMD_ROOT)" OMD_VERSION="$(OMD_VERSION)" BUILD_CACHE="$(BUILD_CACHE)" ../build/build_cached "$(MAKE)" "$$p" "$(DISTRO_NAME)/$(DISTRO_VERSION)/$(shell uname -m)"; \
	    echo "build-cached: $$p (took $$(( $$(date +%s) - NOW ))s)"; \
	done


build:
	@set -e ; cd packages ; for p in $(PACKAGES) ; do \
	    $(MAKE) -C $$p build ; \
	done

speed:
	@set -e ; cd packages ; for p in $(PACKAGES) ; do \
	    ( NOW=$$(date +%s) ; \
	    $(MAKE) -C $$p build > ../$$p.log 2>&1 \
	      && echo "$$p(ok - $$(( $$(date +%s) - NOW ))s)" \
	     || echo "$$p(ERROR - $$(( $$(date +%s) - NOW ))s)" ) & \
	done ; wait ; echo "FINISHED."

pack:
	rm -rf $(DESTDIR)
	mkdir -p $(DESTDIR)$(OMD_PHYSICAL_BASE)
	A="$(OMD_PHYSICAL_BASE)" ; ln -s $${A:1} $(DESTDIR)/omd
	@set -e; MB1=0 ; cd packages ; for p in $(PACKAGES) ; do \
	    NOW=$$(date +%s); \
	    $(MAKE) -C $$p DESTDIR=$(DESTDIR) install ; \
	    for hook in $$(cd $$p ; ls *.hook 2>/dev/null) ; do \
	        mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/omd/hooks ; \
	        install -m 755 $$p/$$hook $(DESTDIR)$(OMD_ROOT)/lib/omd/hooks/$${hook%.hook} ; \
	    done ; \
	    MB2=$$(du -sm $(DESTDIR) | awk '{ print $$1 }'); \
	    echo "pack: $$p (took $$(( $$(date +%s) - NOW ))s) disk usage: $$(( MB2 - MB1 ))MB"; \
	    MB1=$$MB2; \
	done

	sed -i -e 's|###APACHE_MODULE_DIR###|$(APACHE_MODULE_DIR)|g' $(DESTDIR)$(OMD_ROOT)/lib/omd/hooks/*
	sed -i -e 's|###APACHE_INCLUDEOPT###|$(APACHE_INCLUDEOPT)|g' $(DESTDIR)$(OMD_ROOT)/lib/omd/hooks/*

	# Repair packages that install with silly modes (such as Nagios)
	chmod -R o+Xr $(DESTDIR)$(OMD_ROOT)
	$(MAKE) install-global

	# Install skeleton files (subdirs skel/ in packages' directories)
	mkdir -p $(DESTDIR)$(OMD_ROOT)/skel
	@set -e ; cd packages ; for p in $(PACKAGES) ; do \
	    if [ -d "$$p/skel" ] ; then  \
	      tar cf - -C $$p/skel --exclude="*~" --exclude=".gitignore" . | tar xvf - -C $(DESTDIR)$(OMD_ROOT)/skel ; \
	    fi ;\
	    $(MAKE) DESTDIR=$(DESTDIR) SKEL=$(DESTDIR)$(OMD_ROOT)/skel -C $$p skel ;\
	done

	# Create permissions file for skel
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/omd
	@set -e ; cd packages ; for p in $(PACKAGES) ; do \
	    if [ -e $$p/skel.permissions ] ; then \
	        echo "# $$p" ; \
	        cat $$p/skel.permissions ; \
	    fi ; \
	done > $(DESTDIR)$(OMD_ROOT)/share/omd/skel.permissions

	# Make sure, all permissions in skel are set to 0755, 0644
	./build/check_skel_permissions $(DESTDIR)$(OMD_ROOT)/skel $(DESTDIR)$(OMD_ROOT)/share/omd/skel.permissions*

	@failed=$$(find $(DESTDIR)$(OMD_ROOT)/lib64 2>/dev/null) ; \
	if [ -n "$$failed" ] ; then \
	    echo "ERROR: Invalid lib installpath. Library files must be installed in prefix/lib" ; \
	    echo "$$failed" ; \
	fi

	# Fix packages which did not add ###ROOT###
	find $(DESTDIR)$(OMD_ROOT)/skel -type f -exec sed -e 's+$(OMD_ROOT)+###ROOT###+g' -i "{}" \;

	# Remove site-specific directories that went under /omd/version
	rm -rf $(DESTDIR)/{var,tmp,etc,local,man}
	rm -rf $(DESTDIR)$(OMD_ROOT)/{var,tmp,etc,local,man}

	# bail out if some patches did not apply
	@rejected=$$(find $(DESTDIR)$(OMD_ROOT)/skel -type f -name \*.rej) ; \
	if [ -n "$$rejected" ] ; then \
	    echo "Found patch reject files, bailing out:" ; \
	    echo "$$rejected" ; \
	    exit 1; \
	fi

	find $(DESTDIR)$(OMD_ROOT)/ -type f -name \*.pyc -delete
	find $(DESTDIR)$(OMD_ROOT)/ -type d -name __pycache__ -print0 | xargs -0 -n 500 rm -rf
	-find \
    	$(DESTDIR)$(OMD_ROOT)/bin/ \
    	$(DESTDIR)$(OMD_ROOT)/lib/ \
    	-type f \
    	\( \
        	-not -name "*.dbg" \
        	-not -name "waitmax" \
        	-not -name "agent_modbus" \
        	-not -path "*/.local-chromium/*" \
    	\) \
    	-print0 \
  	| xargs -0 -n 500 strip 2>&1 \
  	| grep -ivP 'File format not recognized|Unable to recognise the format|File truncated|has no sections'

	# Pack the whole stuff into a tarball
	tar czf $(BIN_TGZ) --owner=root --group=root -C $(DESTDIR) .

clean:
	rm -rf $(DESTDIR)
	@set -e ; cd packages ; for p in $(PACKAGES) ; do \
	    $(MAKE) -C $$p clean ; \
	done

# Create installations files that do not lie beyond /omd/versions/$(OMD_VERSION)
# and files not owned by a specific package.
install-global:
	# Create link to default version
	ln -s $(OMD_VERSION) $(DESTDIR)$(OMD_BASE)/versions/default

	# Create global symbolic links. Those links are share between
	# all installed versions and refer to the default version.
	mkdir -p $(DESTDIR)/usr/bin
	ln -sfn /omd/versions/default/bin/omd $(DESTDIR)/usr/bin/omd
	mkdir -p $(DESTDIR)/usr/share/man/man8
	ln -sfn /omd/versions/default/share/man/man8/omd.8.gz $(DESTDIR)/usr/share/man/man8/omd.8.gz
	mkdir -p $(DESTDIR)/etc/init.d
	ln -sfn /omd/versions/default/share/omd/omd.init $(DESTDIR)/etc/init.d/omd
	mkdir -p $(DESTDIR)/usr/lib/systemd/system/
	ln -sfn /omd/versions/default/share/omd/omd.service $(DESTDIR)/usr/lib/systemd/system/omd.service
	mkdir -p $(DESTDIR)$(APACHE_CONF_DIR)
	ln -sfn /omd/versions/default/share/omd/apache.conf $(DESTDIR)$(APACHE_CONF_DIR)/zzz_omd.conf

	# Base directories below /omd
	mkdir -p $(DESTDIR)$(OMD_BASE)/sites
	mkdir -p $(DESTDIR)$(OMD_BASE)/apache


	# Information about distribution and OMD
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/omd
	install -m 644 distros/Makefile.$(DISTRO_NAME)_$(DISTRO_VERSION) $(DESTDIR)$(OMD_ROOT)/share/omd/distro.info
	echo -e "OMD_VERSION = $(OMD_VERSION)\nOMD_PHYSICAL_BASE = $(OMD_PHYSICAL_BASE)" > $(DESTDIR)$(OMD_ROOT)/share/omd/omd.info

	# README files and license information
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/doc
	install -m 644 README.md    $(DESTDIR)$(OMD_ROOT)/share/doc/README
	install -m 644 Changelog    $(DESTDIR)$(OMD_ROOT)/share/doc/CHANGELOG
	install -m 644 COPYING TEAM $(DESTDIR)$(OMD_ROOT)/share/doc

# Create source tarball. This currently only works in a checked out GIT
# repository.
$(SOURCE_TGZ) dist:
	git -c tar.umask=0022 archive --prefix=$(SOURCE_NAME)/ --format=tar.gz --output=$(SOURCE_TGZ) HEAD

# Build RPM from source code.
# When called from a git repository this uses 'make dist' and thus 'git archive'
# to create the source rpm.
rpm: omd.spec
	test -f $(SOURCE_TGZ) || ( test -d .git && $(MAKE) $(SOURCE_TGZ) || $(MAKE) $(SOURCE_TGZ) )
	mkdir -p $(RPM_TOPDIR)/{SOURCES,BUILD,RPMS,SRPMS,SPECS}
	cp $(SOURCE_TGZ) $(RPM_TOPDIR)/SOURCES
	# NO_BRP_STALE_LINK_ERROR ignores errors when symlinking from skel to
	# share,lib,bin because the link has a invalid target until the site is created
	NO_BRP_STALE_LINK_ERROR="yes" \
		rpmbuild -bb \
		--define "_topdir $(RPM_TOPDIR)" \
		--buildroot=$$(pwd)/rpm.buildroot \
		omd.spec
	mv -v $(RPM_TOPDIR)/RPMS/*/*.rpm .
	rm -rf $(RPM_TOPDIR) rpm.buildroot

# Build DEB from prebuild binary. This currently needs 'make dist' and thus only
# works within a GIT repository.
deb-environment:
	@if test -z "$(DEBFULLNAME)" || test -z "$(DEBEMAIL)"; then \
	  echo "please read 'man dch' and set DEBFULLNAME and DEBEMAIL" ;\
	  exit 1; \
	fi

# create a debian/changelog to build the package
deb-changelog: deb-environment
	# this is a hack!
	rm -f debian/changelog
	dch --create --package omd-$(OMD_VERSION) \
	    --newversion $(OMD_PATCH_LEVEL).$(DISTRO_CODE) "`cat debian/changelog.tmpl`"
	dch --release "releasing ...."

deb: deb-changelog
	sed -e 's/###OMD_VERSION###/$(OMD_VERSION)/' \
	    -e 's/###BUILD_PACKAGES###/$(BUILD_PACKAGES)/' \
	    -e 's/###OS_PACKAGES###/$(OS_PACKAGES)/' \
	    -e '/Depends:/s/\> /, /g' \
	    -e '/Depends:/s/@/ /g' \
	   `pwd`/debian/control.in > `pwd`/debian/control
	# used when putting debug binaries in separate file
	#echo "/opt/omd/versions/$(OMD_VERSION)/bin/*.dbg" > `pwd`/debian/omd-$(OMD_VERSION)-debug.install
	#echo "/opt/omd/versions/$(OMD_VERSION)/lib/*.dbg" > `pwd`/debian/omd-$(OMD_VERSION)-debug.install
	#echo "/opt/omd/versions/$(OMD_VERSION)/lib/mod_gearman/*.dbg" > `pwd`/debian/omd-$(OMD_VERSION)-debug.install
	#echo "/opt/omd/versions/$(OMD_VERSION)/lib/naemon/*.dbg" > `pwd`/debian/omd-$(OMD_VERSION)-debug.install
	fakeroot debian/rules clean
	debuild --no-lintian -i\.git -I\.git \
			-iomd-bin-$(OMD_VERSION).tar.gz \
			-Iomd-bin-$(OMD_VERSION).tar.gz \
			-i.gitignore -I.gitignore \
			-uc -us -rfakeroot -b

version:
	@if [ -z "$(VERSION)" ] ; then \
	    newversion=$$(dialog --stdout --inputbox "New Version:" 0 0 "$(OMD_VERSION)") ; \
	else \
	    newversion=$(VERSION) ; \
	fi ; \
	if [ -n "$$newversion" ] && [ "$$newversion" != "$(OMD_VERSION)" ]; then \
	    sed -ri 's/^(OMD_VERSION[[:space:]]*= *).*/\1'"$$newversion/" Makefile.omd ; \
	    sed -ri 's/^(OMD_SERIAL[[:space:]]*= *).*/\1'"$(NEWSERIAL)/" Makefile.omd ; \
	    sed -ri 's/^(OMD_PATCH_LEVEL[[:space:]]*= *).*/\1'"1/" Makefile.omd ; \
	    sed -ri 's/^(OMD_VERSION[[:space:]]*= *).*/\1"'"$$newversion"'"/' packages/omd/omd ; \
	    sed -ri 's/Version:.*/Version: '$$newversion'/' packages/omd/index.html ; \
	fi ;

changelog: Changelog
Changelog:
	./t/changelog.pl --write

release_notes_blog: release_notes_blog.md
release_notes_blog.md:
	./t/changelog.pl -r --tag=$(shell git describe --tags --abbrev=0) > release_notes_blog.md
	@echo "release_notes_blog.md written"

test:
	t/test_all.sh

timedtest:
	for file in $$(ls -1 t/*.t); do \
		printf "%-60s" $$file; \
		output=$$(/usr/bin/time -f %e ./t/test_all.sh $$file 2>&1); \
		if [ $$? != 0 ]; then \
			printf "% 8s \n" "FAILED"; \
		else \
			time=$$(echo "$$output" | tail -n1); \
			printf "% 8ss\n" $$time; \
		fi; \
	done

omd.spec: omd.spec.in Makefile.omd Makefile
	sed -e 's/^Requires:.*/Requires:        $(OS_PACKAGES)/' \
	    -e 's/%{version}/$(OMD_VERSION)/g' \
	    -e 's/^Version:.*/Version: $(DISTRO_CODE)/' \
	    -e 's/^Release:.*/Release: $(OMD_PATCH_LEVEL)/' \
	    -e 's#@APACHE_CONFDIR@#$(APACHE_CONF_DIR)#g' \
	    -e 's#@APACHE_NAME@#$(APACHE_NAME)#g' \
	    -e 's#@APACHE_INCLUDEOPT@#$(APACHE_INCLUDEOPT)#g' \
	    omd.spec.in > omd.spec
