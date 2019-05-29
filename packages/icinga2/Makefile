include ../../Makefile.omd

NAME = icinga2
VERSION = 2.9.2
DIR = $(NAME)-$(VERSION)
BOOSTDIR=boost_1_60_0
BOOSTDEST=$(shell pwd)/$(BOOSTDIR)-dest
CMAKE=cmake
CMAKEDIR=cmake-3.5.0
CMAKEDEST=$(shell pwd)/$(CMAKEDIR)-dest

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

BUILD_BOOST=
ifeq ($(DISTRO_INFO),CENTOS 6)
BUILD_BOOST=1
endif
ifneq (,$(findstring SLES 11SP,$(DISTRO_INFO)))
BUILD_BOOST=1
endif
ifdef BUILD_BOOST
EXTRA_BUILD_DEPS=build_env_for_sles11
CONFIGUREOPTS+=-DCMAKE_EXE_LINKER_FLAGS=-lrt
# workaround for https://bugzilla.redhat.com/show_bug.cgi?id=849791#c8
CONFIGUREOPTS+=-DBoost_NO_BOOST_CMAKE=ON
CONFIGUREOPTS+=-DBoost_NO_SYSTEM_PATHS=ON
CONFIGUREOPTS+=-DBoost_USE_STATIC_LIBS=ON
CONFIGUREOPTS+=-DBOOST_ROOT=$(BOOSTDEST)
CONFIGUREOPTS+=-DBOOST_INCLUDEDIR=$(BOOSTDEST)/include
CONFIGUREOPTS+=-DBOOST_LIBRARYDIR=$(BOOSTDEST)/lib
#CONFIGUREOPTS+=-DBoost_DEBUG=ON
CMAKE=$(CMAKEDEST)/bin/cmake
else
EXTRA_BUILD_DEPS=
endif

TMPGCC = $(shell pwd)/../gcc/tmp_gcc
export PATH := $(TMPGCC)/bin/:$(PATH)
export LD_LIBRARY_PATH := $(TMPGCC)/lib64:$(LD_LIBRARY_PATH)
ifneq (,$(findstring CENTOS 6,$(DISTRO_INFO)))
export CC := gcc
export CXX := g++
else ifneq (,$(findstring SLES 11SP4,$(DISTRO_INFO)))
export CC := gcc-4.8
export CXX := g++-4.8
else ifneq (,$(findstring SLES 11SP2,$(DISTRO_INFO)))
export CC := gcc
export CXX := g++
else ifneq (,$(findstring SLES 11SP,$(DISTRO_INFO)))
export CC := gcc-4.7
export CXX := g++-4.7
endif

build: $(EXTRA_BUILD_DEPS)
	tar xzf $(DIR).tar.gz
	mkdir -p $(DIR)/build
	for p in patches/*.patch ; do \
	    echo "applying $$p..." ; \
	    ( cd $(DIR) ; patch -p1 ) < $$p || exit 1; \
	done
	cd $(DIR)/build && \
		export CXXFLAGS=-O2; \
		$(CMAKE) .. $(CONFIGUREOPTS) && \
		make -j1

build_env_for_sles11:
	tar xzf $(CMAKEDIR).tar.gz
	cd $(CMAKEDIR) && \
		./configure --prefix=$(CMAKEDEST) && \
		make -j 4 && \
		make install
	tar xjf $(BOOSTDIR).tar.bz2
	cd $(BOOSTDIR) && \
		./bootstrap.sh --with-libraries=thread,system,program_options,regex,chrono,date_time,atomic --prefix=$(BOOSTDEST) && \
		./bjam cxxflags=-fPIC cflags=-fPIC install

install:
	$(MAKE) DESTDIR=$(DESTDIR) -C $(DIR)/build install
	rm -rf $(DESTDIR)$(OMD_ROOT)/etc
	rm -rf $(DESTDIR)$(OMD_ROOT)/var
	mv $(DESTDIR)$(OMD_ROOT)/sbin/* $(DESTDIR)$(OMD_ROOT)/bin/
	rmdir $(DESTDIR)$(OMD_ROOT)/sbin
	mv $(DESTDIR)$(OMD_ROOT)/lib*/icinga2/* $(DESTDIR)$(OMD_ROOT)/lib/
	rm -rf $(DESTDIR)$(OMD_ROOT)/lib*/icinga2
	sed   -e "s#/lib/icinga2/sbin/icinga2#/lib/sbin/icinga2#g" -i $(DESTDIR)$(OMD_ROOT)/bin/icinga2
	sed -e "s#/lib64/icinga2/sbin/icinga2#/lib/sbin/icinga2#g" -i $(DESTDIR)$(OMD_ROOT)/bin/icinga2
	strip $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins/check_nscp_api
	find $(DESTDIR)$(OMD_ROOT)/lib/ -name icinga2 -type f -exec strip {} \;
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/doc/icinga2

skel:
	mkdir -p $(SKEL)/etc/icinga2
	cp -rp $(DIR)/etc/icinga2/* $(SKEL)/etc/icinga2/
	chmod 644 $(SKEL)/etc/icinga2/scripts/*
	rm -rf $(SKEL)/etc/icinga2/conf.d/win32
	mv $(SKEL)/etc/icinga2/constants.conf.cmake $(SKEL)/etc/icinga2/constants.conf
	mkdir -p $(SKEL)/etc/bash_completion.d
	install -m 0644 $(DIR)/etc/bash_completion.d/icinga2 $(SKEL)/etc/bash_completion.d
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

upstream:
	rm -rf icinga2 icinga2-master
	git clone --depth=1 https://github.com/Icinga/icinga2.git
	mv icinga2 icinga2-master
	cd icinga2-master && echo 'set(GIT_VERSION "'$$(git tag -l | tail -n 1)'-git-'$$(git log --format=%h -1 | tr v r)'")' >> CMakeLists.txt
	tar cfz icinga2-master.tar.gz icinga2-master
	rm -rf icinga2-master

githubrelease:
	git rm icinga2-*.tar.gz
	wget "https://github.com/Icinga/icinga2/archive/v$(VERSION).tar.gz"
	mv v$(VERSION).tar.gz icinga2-$(VERSION).tar.gz
	git add *.gz
