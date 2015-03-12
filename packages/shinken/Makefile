include ../../Makefile.omd


SHINKEN=shinken-1.4.1
SHINKEN_FILE=$(SHINKEN).tar.gz
SHINKEN_URL=http://shinken-monitoring.org/pub/$(SHINKEN).tar.gz
#
# Python Remote Objects
ifeq ($(DISTRO_NAME),CENTOS)
  ifeq ($(DISTRO_VERSION),5)
    PYRO=Pyro-3.12
    PYRO_FILE=$(PYRO).tar.gz
    PYRO_URL=https://pypi.python.org/packages/source/P/Pyro/$(PYRO_FILE)
  else
    PYRO=Pyro4-4.18
    PYRO_FILE=$(PYRO).tar.gz
    PYRO_URL=https://pypi.python.org/packages/source/P/Pyro4/$(PYRO_FILE)
  endif
else
    PYRO=Pyro4-4.18
    PYRO_FILE=$(PYRO).tar.gz
    PYRO_URL=https://pypi.python.org/packages/source/P/Pyro4/$(PYRO_FILE)
endif
#
# Python Multiprocessing
MP=multiprocessing-2.6.2.1
MP_FILE=$(MP).tar.gz
MP_URL=http://pypi.python.org/packages/source/m/multiprocessing/$(MP_FILE)
#
# Simple JSON (not included in CentOS' python2.4)
ifeq ($(DISTRO_NAME),CENTOS)
  ifeq ($(DISTRO_VERSION),5)
    SJSON=simplejson-2.1.2
  else
    SJSON=simplejson-3.3.0
  endif
else
  SJSON=simplejson-3.3.0
endif
SJSON_FILE=$(SJSON).tar.gz
SJSON_URL=http://pypi.python.org/packages/source/s/simplejson/$(SJSON_FILE)
#
# Setup-Tools (needed to install Pyro on CentOS)
STOOLS=setuptools-0.6c11
STOOLS_FILE=$(STOOLS).tar.gz
STOOLS_URL=http://pypi.python.org/packages/source/s/setuptools/$(STOOLS_FILE)
#
# ctypes is only needed for CentOS and it's Python 2.4
CTYPES=ctypes-1.0.2
CTYPES_FILE=$(CTYPES).tar.gz
CTYPES_URL=http://downloads.sourceforge.net/project/ctypes/ctypes/1.0.2/$(CTYPES_FILE)
#
# Hopefully this is never needed
SQLITE=pysqlite-2.6.0
SQLITE_FILE=$(SQLITE).tar.gz
SQLITE_URL=http://pysqlite.googlecode.com/files/$(SQLITE_FILE)
#
# MongoDB
MONGODB=mongodb-linux-i686-2.4.1
ifeq ($(shell uname -m),x86_64)
  MONGODB=mongodb-linux-x86_64-2.4.1
endif
MONGODB_FILE=$(MONGODB).tgz
MONGODB_URL=http://fastdl.mongodb.org/linux/$(MONGODB_FILE)
#
# Python bindings for MongoDB
ifeq ($(DISTRO_NAME),CENTOS)
  ifeq ($(DISTRO_VERSION),5)
    PYMONGO=pymongo-2.1.1
  else
    PYMONGO=pymongo-2.5.2
  endif
else
  PYMONGO=pymongo-2.5.2
endif
PYMONGO_FILE=$(PYMONGO).tar.gz
PYMONGO_URL=http://pypi.python.org/packages/source/p/pymongo/$(PYMONGO_FILE)
#
# Hashlib (for Python 2.4)
HASHLIB=hashlib-20081119
HASHLIB_FILE=$(HASHLIB).tar.gz
HASHLIB_URL=http://code.krypto.org/python/hashlib/$(HASHLIB_FILE)
#
# This is where the python modules are going to be installed to
LOCALPYTHONDIR=$(DESTDIR)$(OMD_ROOT)/lib/python

# Find the directory where python distutils are located
PYTHONPATH=
export PYTHONPATH
RM_DISTU=$(shell rm -rf /tmp/temp_distutils)
DISTUTILS=$(shell python -c "import sys; import os; print [os.path.join(p, 'distutils') for p in sys.path if os.path.exists(os.path.join(p, 'distutils'))][0]")
# This is where the distutils module is temporary copied to
TMP_DISTU=/tmp/temp_distutils
PYTHONPATH=$(TMP_DISTU):$(LOCALPYTHONDIR)
export PYTHONPATH

build:
	test -f ${SHINKEN_FILE} || wget $(SHINKEN_URL)
	tar xzf $(SHINKEN_FILE)
	#set -e ; for p in patches/*.patch ; do \
	#    echo "applying $$p..." ; \
	#    ( cd $(SHINKEN) ; patch -p1 -b ) < $$p ; \
	#done
	test -f $(PYRO_FILE) || wget $(PYRO_URL)
	tar xzf $(PYRO_FILE)
	test -f $(MP_FILE) || wget $(MP_URL)
	tar xzf $(MP_FILE)
	test -f $(SJSON_FILE) || wget $(SJSON_URL)
	tar xzf $(SJSON_FILE)
	test -f $(STOOLS_FILE) || wget $(STOOLS_URL)
	tar xzf $(STOOLS_FILE)
	test -f $(CTYPES_FILE) || wget $(CTYPES_URL)
	tar xzf $(CTYPES_FILE)
	test -f $(PYMONGO_FILE) || wget $(PYMONGO_URL)
	tar xzf $(PYMONGO_FILE)
	test -f $(MONGODB_FILE) || wget $(MONGODB_URL)
	tar xzf $(MONGODB_FILE)
	test -f $(HASHLIB_FILE) || wget $(HASHLIB_URL)
	tar xzf $(HASHLIB_FILE)
	#test -f $(SQLITE_FILE) || wget $(SQLITE_URL)
	#tar xzf $(SQLITE_FILE)
	if [ $(DISTRO_NAME) = "CENTOS" ] && [ $(DISTRO_VERSION) = "5" ]; then \
		echo it is a centos 5; \
		echo which has python 2.4; \
		echo we need to remove the shinken webui; \
		rm -f $(SHINKEN)/shinken/modules/active_directory_ui.py; \
	fi


install:
	rm -rf $(TMP_DISTU)
	mkdir -p $(LOCALPYTHONDIR)
	$(MAKE) installshinken
	$(MAKE) repairdistutils
	$(MAKE) installstools
	$(MAKE) installpyro
	$(MAKE) installmp
	$(MAKE) installjson
	$(MAKE) installpymongo
	$(MAKE) installmongodb
	echo "distro is " $(DISTRO_NAME)
	if [ $(DISTRO_NAME) = "CENTOS" ]; then \
		$(MAKE) installctypes; \
		$(MAKE) installhashlib; \
	fi
	#$(MAKE) installsqlite
	rm -rf $(TMP_DISTU)
	# cleanup the tmp directory
	for tmpfile in $(DESTDIR)$(OMD_ROOT)/tmp/easy_install* ; do \
		rm -f $$tmpfile ; \
	done
	for tmpfile in $(DESTDIR)$(OMD_ROOT)/tmp/pyro-* ; do \
		rm -f $$tmpfile ; \
	done


installshinken:
	# bin/shinken-* startfiles
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(SHINKEN)/bin/shinken-arbiter $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(SHINKEN)/bin/shinken-broker $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(SHINKEN)/bin/shinken-scheduler $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(SHINKEN)/bin/shinken-poller $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(SHINKEN)/bin/shinken-reactionner $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(SHINKEN)/bin/shinken-admin $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(SHINKEN)/bin/shinken-receiver $(DESTDIR)$(OMD_ROOT)/bin

	# shinken py-files
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/shinken
	cp -r $(SHINKEN)/shinken $(DESTDIR)$(OMD_ROOT)/lib/shinken

	install -m 755 $(SHINKEN)/bin/shinken-discovery $(DESTDIR)$(OMD_ROOT)/bin
	cp -r $(SHINKEN)/libexec $(DESTDIR)$(OMD_ROOT)/lib/shinken

	install -m 755 merge-shinken-config $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 merge-shinken-specific-config $(DESTDIR)$(OMD_ROOT)/bin


repairdistutils:
	mkdir $(TMP_DISTU)
	cp -r $(DISTUTILS) $(TMP_DISTU)
	# SuSE prevents installation of modules to private locations
	rm -f /tmp/temp_distutils/distutils/distutils.cfg
	# No longer...


installstools:
	( cd $(STOOLS) ; python setup.py install \
		--home=$(DESTDIR)$(OMD_ROOT) \
		--install-platlib=$(LOCALPYTHONDIR) \
		--install-purelib=$(LOCALPYTHONDIR) \
		--install-scripts=$(DESTDIR)$(OMD_ROOT)/tmp \
		--install-data=$(DESTDIR)$(OMD_ROOT)/tmp )
  

installpyro:
	( cd $(PYRO) ; python setup.py install \
		--home=$(DESTDIR)$(OMD_ROOT) \
		--install-platlib=$(LOCALPYTHONDIR) \
		--install-purelib=$(LOCALPYTHONDIR) \
		--install-scripts=$(DESTDIR)$(OMD_ROOT)/tmp \
		--install-data=$(DESTDIR)$(OMD_ROOT)/tmp )


installmp:
	( cd $(MP) ; python setup.py install \
		--home=$(DESTDIR)$(OMD_ROOT) \
		--install-platlib=$(LOCALPYTHONDIR) \
		--install-scripts=$(DESTDIR)$(OMD_ROOT)/tmp \
		--install-data=$(DESTDIR)$(OMD_ROOT)/tmp )


installsqlite:
	( cd $(SQLITE) ; python setup.py install \
		--home=$(DESTDIR)$(OMD_ROOT) \
		--install-platlib=$(LOCALPYTHONDIR) \
		--install-scripts=$(DESTDIR)$(OMD_ROOT)/tmp \
		--install-data=$(DESTDIR)$(OMD_ROOT)/tmp )


installjson:
	( cd $(SJSON) ; python setup.py install \
		--home=$(DESTDIR)$(OMD_ROOT) \
		--install-platlib=$(LOCALPYTHONDIR) \
		--install-scripts=$(DESTDIR)$(OMD_ROOT)/tmp \
		--install-data=$(DESTDIR)$(OMD_ROOT)/tmp )


installctypes:
	( cd $(CTYPES) ; python setup.py install \
		--home=$(DESTDIR)$(OMD_ROOT) \
		--install-platlib=$(LOCALPYTHONDIR) \
		--install-scripts=$(DESTDIR)$(OMD_ROOT)/tmp \
		--install-data=$(DESTDIR)$(OMD_ROOT)/tmp )

installpymongo:
	( cd $(PYMONGO) ; python setup.py install \
		--home=$(DESTDIR)$(OMD_ROOT) \
		--install-platlib=$(LOCALPYTHONDIR) \
		--install-scripts=$(DESTDIR)$(OMD_ROOT)/tmp \
		--install-data=$(DESTDIR)$(OMD_ROOT)/tmp )

installhashlib:
	( cd $(HASHLIB) ; python setup.py install \
		--home=$(DESTDIR)$(OMD_ROOT) \
		--install-platlib=$(LOCALPYTHONDIR) \
		--install-scripts=$(DESTDIR)$(OMD_ROOT)/tmp \
		--install-data=$(DESTDIR)$(OMD_ROOT)/tmp )

installmongodb:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(MONGODB)/bin/mongod $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(MONGODB)/bin/mongo  $(DESTDIR)$(OMD_ROOT)/bin


clean:
	rm -rf $(SHINKEN)
	rm -rf $(PYRO)
	rm -rf $(MP)
	rm -rf $(SJSON)
	rm -rf $(STOOLS)
	rm -rf $(CTYPES)
	rm -rf $(SQLITE)
	rm -rf $(PYMONGO)
	rm -rf $(MONGODB)
	rm -rf $(HASHLIB)
