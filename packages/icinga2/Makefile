include ../../Makefile.omd

NAME = icinga2
VERSION = 2.2.4
DIR = $(NAME)-$(VERSION)

.PHONY: skel

# Configure options for Icinga. Since we want to compile
# as non-root, we use our own user and group for compiling.
# All files will be packaged as user 'root' later anyway.
CONFIGUREOPTS = \
    -DICINGA2_GIT_VERSION_INFO=ON \
    -DCMAKE_INSTALL_PREFIX=$(OMD_ROOT) \
    -DINSTALL_SBINDIR=$(OMD_ROOT)/bin \
    -DICINGA2_WITH_MYSQL=OFF \
    -DICINGA2_WITH_PGSQL=OFF \
    -DICINGA2_USER=root \
    -DICINGA2_GROUP=root

build:
	tar xzf $(DIR).tar.gz
	mkdir -p $(DIR)/build
	for p in patches/*.patch ; do \
	    echo "applying $$p..." ; \
	    ( cd $(DIR) ; patch -p1 ) < $$p || exit 1; \
	done
	cd $(DIR)/build; cmake .. $(CONFIGUREOPTS)
	cd $(DIR)/build; make

install:
	$(MAKE) DESTDIR=$(DESTDIR) -C $(DIR)/build install
	rm -rf $(DESTDIR)$(OMD_ROOT)/etc
	rm -rf $(DESTDIR)$(OMD_ROOT)/var
	mv $(DESTDIR)$(OMD_ROOT)/sbin/* $(DESTDIR)$(OMD_ROOT)/bin/
	rmdir $(DESTDIR)$(OMD_ROOT)/sbin
	mv $(DESTDIR)$(OMD_ROOT)/lib*/icinga2/* $(DESTDIR)$(OMD_ROOT)/lib/
	rm -rf $(DESTDIR)$(OMD_ROOT)/lib*/icinga2
	mkdir -p $(DESTDIR)$(OMD_ROOT)/etc/bash_completion.d
	install $(DIR)/etc/bash_completion.d/icinga2 $(DESTDIR)$(OMD_ROOT)/etc/bash_completion.d

skel:
	mkdir -p $(SKEL)/etc/icinga2
	cp -rp $(DIR)/etc/icinga2/* $(SKEL)/etc/icinga2/
	rm -rf $(SKEL)/etc/icinga2/conf.d/win32
	mv $(SKEL)/etc/icinga2/constants.conf.cmake $(SKEL)/etc/icinga2/constants.conf
	mv $(SKEL)/etc/icinga2/init.conf.cmake $(SKEL)/etc/icinga2/init.conf
	sed -i -e 's/@ICINGA2_USER@/###SITE###/g' \
	       -e 's/@ICINGA2_GROUP@/###SITE###/g' \
	       -e 's/@ICINGA2_PLUGINDIR@/###ROOT###\/lib\/nagios\/plugins/g' \
	    $(SKEL)/etc/icinga2/init.conf \
	    $(SKEL)/etc/icinga2/constants.conf
	echo 'const SysconfDir    = "###ROOT###/etc"'                       >> $(SKEL)/etc/icinga2/init.conf
	echo 'const LocalStateDir = "###ROOT###/var/icinga2"'               >> $(SKEL)/etc/icinga2/init.conf
	echo 'const RunDir        = "###ROOT###/tmp/icinga2"'               >> $(SKEL)/etc/icinga2/init.conf
	echo 'const StatePath     = "###ROOT###/var/icinga2/state"'         >> $(SKEL)/etc/icinga2/init.conf
	echo 'const ObjectsPath   = "###ROOT###/tmp/icinga2/icinga2.debug"' >> $(SKEL)/etc/icinga2/init.conf
	echo 'const VarsPath      = "###ROOT###/tmp/icinga2/icinga2.vars"'  >> $(SKEL)/etc/icinga2/init.conf
	echo 'const PidPath       = "###ROOT###/tmp/run/icinga2.pid"'       >> $(SKEL)/etc/icinga2/init.conf
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
	echo 'log_dir         = "###ROOT###/var/log/icinga2"' >> $(SKEL)/etc/icinga2/features-available/compatlog.conf
	echo '}'                                              >> $(SKEL)/etc/icinga2/features-available/compatlog.conf
	# fix logfile folder
	sed -e 's/path.*=.*/path = "###ROOT###\/var\/log\/icinga2.log"/g' -i $(SKEL)/etc/icinga2/features-available/mainlog.conf
	# prepare perfdata
	sed -e 's/ }//g' -i $(SKEL)/etc/icinga2/features-available/perfdata.conf
	echo 'host_perfdata_path = "var/pnp4nagios/spool/host-perfdata"'       >> $(SKEL)/etc/icinga2/features-available/perfdata.conf
	echo 'service_perfdata_path = "var/pnp4nagios/spool/service-perfdata"' >> $(SKEL)/etc/icinga2/features-available/perfdata.conf
	echo 'host_temp_path = "var/icinga2/host-perfdata"'                    >> $(SKEL)/etc/icinga2/features-available/perfdata.conf
	echo 'service_temp_path = "var/icinga2/service-perfdata"'              >> $(SKEL)/etc/icinga2/features-available/perfdata.conf
	echo 'rotation_interval = 30'                                          >> $(SKEL)/etc/icinga2/features-available/perfdata.conf
	echo '}'                                                               >> $(SKEL)/etc/icinga2/features-available/perfdata.conf
	sed -e 's/import "generic-host"/import "generic-host"\n  import "host-pnp"/g'      -i $(SKEL)/etc/icinga2/conf.d/hosts.conf
	sed -e 's/import "generic-service"/import "generic-service"\n  import "srv-pnp"/g' -i $(SKEL)/etc/icinga2/conf.d/services.conf

clean:
	rm -rf $(DIR)

upstream:
	rm -rf icinga2 icinga2-master
	git clone --depth=1 https://github.com/Icinga/icinga2.git
	mv icinga2 icinga2-master
	cd icinga2-master && echo 'set(GIT_VERSION "'$$(git tag -l | tail -n 1)'-git-'$$(git log --format=%h -1 | tr v r)'")' >> CMakeLists.txt
	tar cfz icinga2-master.tar.gz icinga2-master
	rm -rf icinga2-master
