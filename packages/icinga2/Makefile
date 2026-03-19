include ../../Makefile.omd

NAME      = icinga2
CHANGELOG = https://github.com/Icinga/icinga2/blob/master/CHANGELOG.md
VERSION   = 2.15.2
# use last version that builds on rhel7...
ifeq ($(DISTRO_CODE),el7)
VERSION   = 2.13.10
endif
DIR       = $(NAME)-$(VERSION)
SRC       = $(NAME)-$(VERSION).tar.xz
BOOSTDIR  = boost_1_79_0
BOOSTDEST = $(BOOSTDIR)-dest
CMAKE     = cmake
CMAKEVER  = 3.31.11
CMAKEDIR  = cmake-$(CMAKEVER)
CMAKEDEST = $(CMAKEDIR)-dest
CMAKEMINVER = 3.17 # use shipped cmake if system cmake is older than this
SHELL     = bash

.PHONY: skel

# Configure options for Icinga. Since we want to compile
# as non-root, we use our own user and group for compiling.
# All files will be packaged as user 'root' later anyway.
CONFIGUREOPTS = \
    -DCMAKE_BUILD_TYPE=RELEASE \
    -DCMAKE_INSTALL_PREFIX=$(OMD_ROOT) \
    -DCMAKE_INSTALL_SYSCONFDIR=$(OMD_ROOT)/etc \
    -DCMAKE_INSTALL_LOCALSTATEDIR=$(OMD_ROOT)/var \
    -DINSTALL_SBINDIR=$(OMD_ROOT)/bin \
    -DICINGA2_PLUGINDIR=$(OMD_ROOT)/lib/monitoring-plugins \
    -DICINGA2_GIT_VERSION_INFO=ON \
    -DICINGA2_USER=root \
    -DICINGA2_WITH_TESTS=OFF \
    -DICINGA2_GROUP=root

EXTRA_BUILD_DEPS=

# build boost if older than shipped version
BOOST_MINOR_VERSION=$(shell grep BOOST_LIB_VERSION /usr/include/boost/version.hpp | grep ^\# | awk -F _ '{ print $$4 }' | tr -d '"')
BUILD_BOOST=0
ifeq ($(shell test $(BOOST_MINOR_VERSION) -lt 79; echo $$?),0)
  BUILD_BOOST=1
endif

# build cmake if older than shipped version
BUILD_CMAKE := $(shell \
cmake_ver="$$( $(CMAKE) --version 2>/dev/null | sed -n '1s/.* //p' )"; \
if [ -z "$$cmake_ver" ]; then \
	echo 1; \
elif [ "$$cmake_ver" != "$(CMAKEVER)" ] && \
		[ "$$(printf '%s\n%s\n' "$$cmake_ver" "$(CMAKEMINVER)" | sort -V | head -n1)" = "$$cmake_ver" ]; then \
	echo 1; \
fi)

ifeq ($(BUILD_BOOST),1)
  EXTRA_BUILD_DEPS+=$(BOOSTDEST)
  CONFIGUREOPTS+=-DCMAKE_EXE_LINKER_FLAGS=-lrt
  # workaround for https://bugzilla.redhat.com/show_bug.cgi?id=849791#c8
  CONFIGUREOPTS+=-DBoost_NO_BOOST_CMAKE=ON
  CONFIGUREOPTS+=-DBoost_NO_SYSTEM_PATHS=ON
  CONFIGUREOPTS+=-DBoost_USE_STATIC_LIBS=ON
  CONFIGUREOPTS+=-DBOOST_ROOT=$(shell pwd)/$(BOOSTDEST)
  CONFIGUREOPTS+=-DBOOST_INCLUDEDIR=$(shell pwd)/$(BOOSTDEST)/include
  CONFIGUREOPTS+=-DBOOST_LIBRARYDIR=$(shell pwd)/$(BOOSTDEST)/lib
  #CONFIGUREOPTS+=-DBoost_DEBUG=ON
  BUILD_CMAKE=1
endif

ifeq ($(BUILD_CMAKE),1)
  CMAKE=$(shell pwd)/$(CMAKEDEST)/bin/cmake
  EXTRA_BUILD_DEPS+=$(CMAKEDEST)
endif

build: $(EXTRA_BUILD_DEPS)
	tar xfJ $(SRC)
	mkdir -p $(DIR)/build
	for p in patches/*.patch ; do \
	    echo "applying $$p..." ; \
	    ( cd $(DIR) ; patch -p1 ) < $$p || exit 1; \
	done
	cd $(DIR)/build && CXXFLAGS="$${CXXFLAGS} -O2 -fpermissive" $(CMAKE) .. $(CONFIGUREOPTS)
	+env CXXFLAGS="$${CXXFLAGS} -O2 -fpermissive" $(MAKE) -C $(DIR)/build
	# save build artifacts and clean build dir to speed up cached builds
	rm -rf ./dest
	$(MAKE) DESTDIR=$(shell pwd)/dest -C $(DIR)/build install
	mv ./dest/$(OMD_ROOT)/* ./dest/.
	rm -rf ./dest/omd
	mkdir -p ./dest/bin
	mv ./dest/sbin/* ./dest/bin/
	rmdir ./dest/sbin
	mkdir -p ./dest/lib
	mv ./dest/lib*/icinga2/* ./dest/lib/
	rm -rf ./dest/lib*/icinga2
	mkdir -p ./dest/etc/icinga2
	rsync -a $(DIR)/etc/icinga2/. ./dest/etc/icinga2/.
	# unpacking as root creates etc/icinga/* with 664 and 775, fix it.
	find ./dest/etc/icinga2/ -type d -exec chmod 755 {} \;
	find ./dest/etc/icinga2/ -type f -exec chmod 644 {} \;
	mkdir -p ./dest/etc/bash_completion.d
	install -m 0644 $(DIR)/etc/bash_completion.d/icinga2 ./dest/etc/bash_completion.d
	rm -rf $(DIR)
	rm -rf $(BOOSTDIR)
	rm -rf $(BOOSTDEST)
	rm -rf $(CMAKEDIR)
	rm -rf $(CMAKEDEST)

build_cmake: $(CMAKEDEST)

$(CMAKEDEST):
	tar xfJ $(CMAKEDIR).tar.xz
	cd $(CMAKEDIR) && ./bootstrap --prefix=$(shell pwd)/$(CMAKEDEST)
	+$(MAKE) -C $(CMAKEDIR)
	+$(MAKE) -C $(CMAKEDIR) install

build_boost: $(BOOSTDEST)

$(BOOSTDEST): $(CMAKEDEST)
	tar xJf $(BOOSTDIR).tar.xz
	cd $(BOOSTDIR) && \
		./bootstrap.sh \
			--with-libraries=iostreams,thread,system,program_options,regex,chrono,date_time,atomic,coroutine,filesystem,context \
			--prefix=$(shell pwd)/$(BOOSTDEST) && \
		./b2 cxxflags=-fPIC cflags=-fPIC install

install:
	rsync -a ./dest/. $(DESTDIR)$(OMD_ROOT)/.
	sed   -e "s#/lib/icinga2/sbin/icinga2#/lib/sbin/icinga2#g" -i $(DESTDIR)$(OMD_ROOT)/bin/icinga2
	sed -e "s#/lib64/icinga2/sbin/icinga2#/lib/sbin/icinga2#g" -i $(DESTDIR)$(OMD_ROOT)/bin/icinga2
	strip $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins/check_nscp_api
	find $(DESTDIR)$(OMD_ROOT)/lib/ -name icinga2 -type f -exec strip {} \;
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/doc/icinga2

skel:
	mkdir -p $(SKEL)/etc/icinga2
	cp -rp ./dest/etc/icinga2/* $(SKEL)/etc/icinga2/
	rm -rf $(SKEL)/etc/icinga2/conf.d/win32
	rm -f $(SKEL)/etc/icinga2/features-*/windowseventlog.conf
	mv $(SKEL)/etc/icinga2/constants.conf.cmake $(SKEL)/etc/icinga2/constants.conf
	mkdir -p $(SKEL)/etc/bash_completion.d
	install -m 0644 ./dest/etc/bash_completion.d/icinga2 $(SKEL)/etc/bash_completion.d
	sed -i -e 's/@ICINGA2_USER@/###SITE###/g' \
	       -e 's/@ICINGA2_GROUP@/###SITE###/g' \
	       -e 's/@ICINGA2_PLUGINDIR@/###ROOT###\/lib\/monitoring\-plugins/g' \
	    $(SKEL)/etc/icinga2/constants.conf
	sed -i -e '/const PluginDir/a /* The directory which contains your local site plugins */\nconst LocalPluginDir = "###ROOT###/local/lib/monitoring-plugins"' \
	    $(SKEL)/etc/icinga2/constants.conf
	printf '\n/* The OMD site name */\nconst OMD_SITE = "###SITE###"\nconst OmdSite = "###SITE###"\n' >> $(SKEL)/etc/icinga2/constants.conf
	printf '\n/* Root folder of this OMD site */\nconst OMD_ROOT = "###ROOT###"\nconst OmdRoot = "###ROOT###"\n' >> $(SKEL)/etc/icinga2/constants.conf
	sed -i -e 's%^const PluginContribDir.*%const PluginContribDir = "###ROOT###/local/lib/monitoring-plugins"%g' \
	    $(SKEL)/etc/icinga2/constants.conf
	# enable livestatus
	ln -sf ../features-available/livestatus.conf $(SKEL)/etc/icinga2/features-enabled/livestatus.conf
	sed -e 's/ }//g' -i $(SKEL)/etc/icinga2/features-available/livestatus.conf
	echo 'socket_type = "unix",'                   >> $(SKEL)/etc/icinga2/features-available/livestatus.conf
	echo 'socket_path = "###ROOT###/tmp/run/live"' >> $(SKEL)/etc/icinga2/features-available/livestatus.conf
	echo '}'                                       >> $(SKEL)/etc/icinga2/features-available/livestatus.conf
	# enable compat logger
	ln -sf ../features-available/compatlog.conf $(SKEL)/etc/icinga2/features-enabled/compatlog.conf
	sed -e 's/ }//g' -i $(SKEL)/etc/icinga2/features-available/compatlog.conf
	echo 'rotation_method = "DAILY"'                      >> $(SKEL)/etc/icinga2/features-available/compatlog.conf
	echo '}'                                              >> $(SKEL)/etc/icinga2/features-available/compatlog.conf
	# prepare perfdata
	sed -e 's/ }//g' -i $(SKEL)/etc/icinga2/features-available/perfdata.conf
	echo 'host_perfdata_path = "var/pnp4nagios/spool/host-perfdata"'       >> $(SKEL)/etc/icinga2/features-available/perfdata.conf
	echo 'service_perfdata_path = "var/pnp4nagios/spool/service-perfdata"' >> $(SKEL)/etc/icinga2/features-available/perfdata.conf
	echo 'host_temp_path = "var/icinga2/host-perfdata"'                    >> $(SKEL)/etc/icinga2/features-available/perfdata.conf
	echo 'service_temp_path = "var/icinga2/service-perfdata"'              >> $(SKEL)/etc/icinga2/features-available/perfdata.conf
	echo 'rotation_interval = 30'                                          >> $(SKEL)/etc/icinga2/features-available/perfdata.conf
	echo '}'                                                               >> $(SKEL)/etc/icinga2/features-available/perfdata.conf
	# fix path to command file
	sed -e 's/ }//g' -i $(SKEL)/etc/icinga2/features-available/command.conf
	echo 'command_path = "###ROOT###/tmp/run/icinga.cmd"' >> $(SKEL)/etc/icinga2/features-available/command.conf
	echo '}'                                              >> $(SKEL)/etc/icinga2/features-available/command.conf
	sed -e 's/import "generic-host"/import "generic-host"\n  import "host-pnp"/g'      -i $(SKEL)/etc/icinga2/conf.d/hosts.conf
	sed -e 's/import "generic-service"/import "generic-service"\n  import "srv-pnp"/g' -i $(SKEL)/etc/icinga2/conf.d/services.conf
	# set useful defaults for ido-mysql
	sed -e 's/^\ *}//g' -i $(SKEL)/etc/icinga2/features-available/ido-mysql.conf
	sed -e '/user = /d' -i $(SKEL)/etc/icinga2/features-available/ido-mysql.conf
	sed -e '/password = /d' -i $(SKEL)/etc/icinga2/features-available/ido-mysql.conf
	echo '  socket_path = "###ROOT###/tmp/run/mysqld/mysqld.sock"' >> $(SKEL)/etc/icinga2/features-available/ido-mysql.conf
	echo '  user        = "root"'                                  >> $(SKEL)/etc/icinga2/features-available/ido-mysql.conf
	echo '  password    = ""'                                      >> $(SKEL)/etc/icinga2/features-available/ido-mysql.conf
	echo '  database    = "icinga"'                                >> $(SKEL)/etc/icinga2/features-available/ido-mysql.conf
	echo '}'                                                       >> $(SKEL)/etc/icinga2/features-available/ido-mysql.conf

clean:
	rm -rf $(DIR)
	rm -rf $(BOOSTDIR)
	rm -rf $(BOOSTDEST)
	rm -rf $(CMAKEDIR)
	rm -rf $(CMAKEDEST)
	rm -rf dest/

package:
	test -f v$(VERSION).tar.gz || wget "https://github.com/Icinga/icinga2/archive/v$(VERSION).tar.gz"
	tar xfz v$(VERSION).tar.gz
	rm -rf $(DIR)/{doc,icinga-installer,agent}
	rm -rf $(DIR)/CHANGELOG.md
	rm -rf $(DIR)/{CONTRIBUTING.md,README.md,CHANGELOG.md}
	sed -e 's/CONTRIBUTING.md//' -i $(DIR)/CMakeLists.txt
	sed -e 's/README.md//' -i $(DIR)/CMakeLists.txt
	sed -e 's/CHANGELOG.md//' -i $(DIR)/CMakeLists.txt
	sed -e '/add_subdirectory(doc)/d' -i $(DIR)/CMakeLists.txt
	sed -e '/add_subdirectory(agent)/d' -i $(DIR)/CMakeLists.txt
	rm -f v$(VERSION).tar.gz
	XZ_OPT=-8 tar cfJ $(SRC) $(DIR)
	rm -rf $(DIR)

upstream: package

# repack boost library tarball and remove unused stuff to make the tarball much smaller
repack_boost:
	test -f $(BOOSTDIR)-orig.tar.xz || cp $(BOOSTDIR).tar.xz $(BOOSTDIR)-orig.tar.xz
	tar xfJ $(BOOSTDIR)-orig.tar.xz
	rm -rf $(BOOSTDIR)/doc
	rm -rf $(BOOSTDIR)/*/*/doc
	rm -rf $(BOOSTDIR)/*/*/test/
	rm -f $(BOOSTDIR).tar.xz
	XZ_OPT=-8 tar cfJ $(BOOSTDIR).tar.xz $(BOOSTDIR)
	rm -rf $(BOOSTDIR)
	ls -la $(BOOSTDIR)-orig.tar.xz $(BOOSTDIR).tar.xz
