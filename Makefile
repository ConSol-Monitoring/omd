SHELL = /bin/bash
# You can select a subset of the packages by overriding this
# variale, e.g. make PACKAGES='nagios rrdtool' pack
PACKAGES=perl-modules \
         python-modules \
         apache-omd \
         mod_python \
         check_logfiles \
         check_mk \
         check_multi \
         check_mysql_health \
         check_oracle_health \
         check_webinject \
         dokuwiki \
         example \
         jmx4perl \
         mk-livestatus \
         mysql-omd \
         icinga \
         icinga2 \
         nagios \
         monitoring-plugins \
         naemon \
         nagvis \
         nrpe \
         nsca \
         omd \
         pnp4nagios \
         pnp4nagios4 \
         rrdtool \
         shinken \
         thruk \
         maintenance \
         gearmand \
         mod-gearman \
         mod-gearman2 \
         naemon-livestatus \
         patch \
         nail \
         notifications-tt

include Makefile.omd

# If you just want to test package building, you can reduce the
# number of packages to just "omd" - to speed up your tests.
# PACKAGES="omd"

# This file is kept by 'make config' and also may override
# the list of packages
-include .config

DESTDIR ?=$(shell pwd)/destdir
RPM_TOPDIR=$$(pwd)/rpm.topdir
DPKG_TOPDIR=$$(pwd)/dpkg.topdir
SOURCE_TGZ=omd-$(OMD_VERSION).tar.gz
BIN_TGZ=omd-bin-$(OMD_VERSION).tar.gz
NEWSERIAL=$$(($(OMD_SERIAL) + 1))
APACHE_NAME=$(APACHE_INIT_NAME)

.PHONY: install-global

omd: build

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
	@set -e ; cd packages ; for p in $(PACKAGES) ; do \
            $(MAKE) -C $$p DESTDIR=$(DESTDIR) install ; \
            for hook in $$(cd $$p ; ls *.hook 2>/dev/null) ; do \
                mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/omd/hooks ; \
                install -m 755 $$p/$$hook $(DESTDIR)$(OMD_ROOT)/lib/omd/hooks/$${hook%.hook} ; \
            done ; \
        done

	# Repair packages that install with silly modes (such as Nagios)
	chmod -R o+Xr $(DESTDIR)$(OMD_ROOT)
	$(MAKE) install-global

	# Install skeleton files (subdirs skel/ in packages' directories)
	mkdir -p $(DESTDIR)$(OMD_ROOT)/skel
	@set -e ; cd packages ; for p in $(PACKAGES) ; do \
            if [ -d "$$p/skel" ] ; then  \
              tar cf - -C $$p/skel --exclude="*~" --exclude=".gitignore" . | tar xvf - -C $(DESTDIR)$(OMD_ROOT)/skel ; \
            fi ;\
            $(MAKE) SKEL=$(DESTDIR)$(OMD_ROOT)/skel -C $$p skel ;\
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
	@failed=$$(find $(DESTDIR)$(OMD_ROOT)/skel -type d -not -perm 0755) ; \
	if [ -n "$$failed" ] ; then \
	    echo "Invalid permissions for skeleton dirs. Must be 0755:" ; \
            echo "I'll fix this for you this time..." ; \
            chmod -c 755 $$failed ; \
            echo "$$failed" ; \
        fi
	@failed=$$(find $(DESTDIR)$(OMD_ROOT)/skel -type f -not -perm 0644) ; \
	if [ -n "$$failed" ] ; then \
	    echo "Invalid permissions for skeleton files. Must be 0644:" ; \
            echo "$$failed" ; \
            echo "I'll fix this for you this time..." ; \
            chmod -c 644 $$failed ; \
        fi

	# Fix packages which did not add ###ROOT###
	find $(DESTDIR)$(OMD_ROOT)/skel -type f | xargs -n1 sed -i -e 's+$(OMD_ROOT)+###ROOT###+g'

	# Remove site-specific directories that went under /omd/version
	rm -rf $(DESTDIR)/{var,tmp}

	# Pack the whole stuff into a tarball
	tar czf $(BIN_TGZ) --owner=root --group=root -C $(DESTDIR) .

clean:
	rm -rf $(DESTDIR)
	@for p in packages/* ; do \
            $(MAKE) -C $$p clean ; \
        done

mrproper:
	git clean -xfd

config:
	@inarray () { \
            elem="$$1" ; \
            shift ; \
            for x in "$$@" ; do if [ $$elem = $$x ] ; then return 0 ; fi ; done ; \
            return 1  ; \
        } ; \
        if [ "$(PACKAGES)" = '*' ] ; \
        then \
            enabled='*' ; \
        else \
            enabled=( $(PACKAGES) ) ; \
        fi ; \
        echo "$$enabled" ; \
        avail=$$(for p in $$(cd packages ; ls) ; do if [ "$$enabled" = '*' ] || inarray $$p $${enabled[@]} ; then en=on ; else en="-" ; fi ; echo -n "$$p - $$en " ; done) ; \
        if packages=$$(dialog --stdout --checklist "Package configuration" 1 0 0 $$avail ) ; \
        then \
            echo "PACKAGES = $$packages" | sed 's/"//g' > .config ; \
        fi


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
	install -m 644 README COPYING TEAM $(DESTDIR)$(OMD_ROOT)/share/doc
	install -m 644 Changelog $(DESTDIR)$(OMD_ROOT)/share/doc/CHANGELOG

# Create source tarball. This currently only works in a checked out GIT 
# repository.
$(SOURCE_TGZ) dist:
	rm -rf omd-$(OMD_VERSION)
	mkdir -p omd-$(OMD_VERSION)
	git archive HEAD | tar xf - -C omd-$(OMD_VERSION)
	tar czf $(SOURCE_TGZ) omd-$(OMD_VERSION)
	rm -rf omd-$(OMD_VERSION)

# Creates source tarball. This does only work well in directories extracted
# from a CLEAN git archive tarball.
$(SOURCE_TGZ)-snap snap:
	rm -rf omd-$(OMD_VERSION)
	mkdir -p omd-$(OMD_VERSION)
	tar cf - --exclude="rpm.topdir" --exclude="*~" --exclude=".gitignore" --exclude "omd-$(OMD_VERSION)" . | tar xf - -C omd-$(OMD_VERSION)
	tar czf $(SOURCE_TGZ) omd-$(OMD_VERSION)
	rm -rf omd-$(OMD_VERSION)

# Build RPM from source code.
# When called from a git repository this uses 'make dist' and thus 'git archive'
# to create the source rpm.
# The second choice is to call this form a CLEAN git archive directory which
# then uses 'make snap' to use that snapshot.
rpm:
	sed -e 's/^Requires:.*/Requires:        $(OS_PACKAGES)/' \
	    -e 's/%{version}/$(OMD_VERSION)/g' \
	    -e 's/^Version:.*/Version: $(DISTRO_CODE)/' \
	    -e 's/^Release:.*/Release: $(OMD_SERIAL)/' \
	    -e 's#@APACHE_CONFDIR@#$(APACHE_CONF_DIR)#g' \
	    -e 's#@APACHE_NAME@#$(APACHE_NAME)#g' \
	    omd.spec.in > omd.spec
	rm -f $(SOURCE_TGZ)
	test -d .git && $(MAKE) $(SOURCE_TGZ) || $(MAKE) $(SOURCE_TGZ)-snap
	mkdir -p $(RPM_TOPDIR)/{SOURCES,BUILD,RPMS,SRPMS,SPECS}
	cp $(SOURCE_TGZ) $(RPM_TOPDIR)/SOURCES
	# NO_BRP_STALE_LINK_ERROR ignores errors when symlinking from skel to
	# share,lib,bin because the link has a invalid target until the site is created
	NO_BRP_STALE_LINK_ERROR="yes" \
	rpmbuild -ba --define "_topdir $(RPM_TOPDIR)" \
	     --buildroot=$$(pwd)/rpm.buildroot omd.spec
	mv -v $(RPM_TOPDIR)/RPMS/*/*.rpm .
	mv -v $(RPM_TOPDIR)/SRPMS/*.src.rpm .
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
	    --newversion 0.$(DISTRO_CODE) "`cat debian/changelog.tmpl`"
	dch --release "releasing ...."

deb: deb-changelog
	sed -e 's/###OMD_VERSION###/$(OMD_VERSION)/' \
	    -e 's/###BUILD_PACKAGES###/$(BUILD_PACKAGES)/' \
	    -e 's/###OS_PACKAGES###/$(OS_PACKAGES)/' \
	    -e '/Depends:/s/\> /, /g' \
	    -e '/Depends:/s/@/ /g' \
	   `pwd`/debian/control.in > `pwd`/debian/control
	fakeroot debian/rules clean
	debuild --no-lintian -i\.git -I\.git \
			-iomd-bin-$(OMD_VERSION).tar.gz \
			-Iomd-bin-$(OMD_VERSION).tar.gz \
			-i.gitignore -I.gitignore \
			-uc -us -rfakeroot
	# -- renaming deb package to DISTRO_CODE dependend name
	# arch=`dpkg-architecture -qDEB_HOST_ARCH` ; \
	# build=`sed -e '1s/.*(\(.*\)).*/\1/;q' debian/changelog` ; \
	# distro=`echo $$build | sed -e 's/build/$(DISTRO_CODE)/' ` ; \
	# echo "$$arch $$build $$distro"; \
	# mv "../omd-$(OMD_VERSION)_$${build}_$${arch}.deb" \
	#  "../omd-$(OMD_VERSION)_$${distro}_$${arch}.deb" ;

deb-snap: deb-environment
	make clean && git checkout -- Makefile.omd packages/omd/omd && \
	make VERSION=`./get_version` version && make deb && \
	git checkout -- Makefile.omd packages/omd/omd

# Only to be used for developement testing setup 
setup: pack xzf alt

# Only for development: install tarball below /
xzf:
	tar xzf $(BIN_TGZ) -C / # HACK: Add missing suid bits if compiled as non-root
	chmod 4755 $(OMD_ROOT)/lib/nagios/plugins/check_{icmp,dhcp}
	$(APACHE_CTL) -k graceful

# On debian based systems register the alternative switches
alt:
	@if which update-alternatives >/dev/null 2>&1; then \
	    update-alternatives --install /omd/versions/default \
		omd /omd/versions/$(OMD_VERSION) $(OMD_SERIAL) \
		--slave /usr/bin/omd omd.bin /omd/versions/$(OMD_VERSION)/bin/omd \
		--slave /usr/share/man/man8/omd.8.gz omd.man8 \
               /omd/versions/$(OMD_VERSION)/share/man/man8/omd.8.gz ; \
	fi ;

version:
	@if [ -z "$(VERSION)" ] ; then \
	    newversion=$$(dialog --stdout --inputbox "New Version:" 0 0 "$(OMD_VERSION)") ; \
        else \
            newversion=$(VERSION) ; \
        fi ; \
	if [ -n "$$newversion" ] && [ "$$newversion" != "$(OMD_VERSION)" ]; then \
	    sed -ri 's/^(OMD_VERSION[[:space:]]*= *).*/\1'"$$newversion/" Makefile.omd ; \
	    sed -ri 's/^(OMD_SERIAL[[:space:]]*= *).*/\1'"$(NEWSERIAL)/" Makefile.omd ; \
	    sed -ri 's/^(OMD_VERSION[[:space:]]*= *).*/\1"'"$$newversion"'"/' packages/omd/omd ; \
	fi ;

test:
	t/test_all.sh
