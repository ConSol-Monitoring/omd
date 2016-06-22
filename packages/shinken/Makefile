include ../../Makefile.omd

PYTHON   = LD_LIBRARY_PATH=$(shell pwd)/../python/tmp.python27/lib \
	   $(shell pwd)/../python/tmp.python27/bin/python

SHINKEN=shinken-1.4.1
SHINKEN_FILE=$(SHINKEN).tar.gz
SHINKEN_URL=http://shinken-monitoring.org/pub/$(SHINKEN).tar.gz
#
# Python Remote Objects
PYRO=Pyro4-4.18
PYRO_FILE=$(PYRO).tar.gz
PYRO_URL=https://pypi.python.org/packages/source/P/Pyro4/$(PYRO_FILE)
#
# Simple JSON (not included in CentOS' python2.4)
SJSON=simplejson-3.3.0
SJSON_FILE=$(SJSON).tar.gz
SJSON_URL=http://pypi.python.org/packages/source/s/simplejson/$(SJSON_FILE)
#
# MongoDB
ifeq ($(shell uname -m),x86_64)
  MONGODB=mongodb-linux-x86_64-2.4.1
else ifeq ($(shell uname -m),$(filter $(shell uname -m),i386 i486 i586 i686))
  MONGODB=mongodb-linux-i686-2.4.1
else ifeq ($(shell uname -m),armv7l)
  # http://andyfelong.com/2015/02/mongodb-on-the-raspberry-pi-2/
  MONGODB=mongodb-linux-armv7l-2.6.3
else ifeq ($(shell uname -m),armv6l)
  MONGODB=mongodb-linux-armv6l-2012-09-16
endif
MONGODB_FILE=$(MONGODB).tgz
MONGODB_URL=http://fastdl.mongodb.org/linux/$(MONGODB_FILE)
#
# Python bindings for MongoDB
PYMONGO=pymongo-2.5.2
PYMONGO_FILE=$(PYMONGO).tar.gz
PYMONGO_URL=http://pypi.python.org/packages/source/p/pymongo/$(PYMONGO_FILE)
#
# This is where the python modules are going to be installed to
LOCALPYTHONDIR=$(DESTDIR)$(OMD_ROOT)/lib/python

# Find the directory where python distutils are located
PYTHONPATH=
export PYTHONPATH
DISTUTILS=$(shell $(PYTHON) -c "import sys; import os; print [os.path.join(p, 'distutils') for p in sys.path if os.path.exists(os.path.join(p, 'distutils'))][0]")
# This is where the distutils module is temporary copied to
TMP_DISTU=$(shell pwd)/temp_distutils
PYTHONPATH=$(TMP_DISTU):$(LOCALPYTHONDIR)
export PYTHONPATH

build: check-python
	test -f ${SHINKEN_FILE} || wget $(SHINKEN_URL)
	tar xzf $(SHINKEN_FILE)
	#set -e ; for p in patches/*.patch ; do \
	#    echo "applying $$p..." ; \
	#    ( cd $(SHINKEN) ; patch -p1 -b ) < $$p ; \
	#done
	test -f $(PYRO_FILE) || wget $(PYRO_URL)
	tar xzf $(PYRO_FILE)
	test -f $(SJSON_FILE) || wget $(SJSON_URL)
	tar xzf $(SJSON_FILE)
	test -f $(PYMONGO_FILE) || wget $(PYMONGO_URL)
	tar xzf $(PYMONGO_FILE)
	test -f $(MONGODB_FILE) || wget $(MONGODB_URL)
	tar xzf $(MONGODB_FILE)

check-python:
	@if [ ! -d ../python/tmp.python27 ]; then \
	    echo "ERROR: You need to build the \"python\" package first" ; \
	    exit 1 ; \
	fi

install:
	rm -rf $(TMP_DISTU)
	mkdir -p $(LOCALPYTHONDIR)
	$(MAKE) installshinken
	$(MAKE) repairdistutils
	$(MAKE) PKG=$(PYRO) installmodule
	$(MAKE) PKG=$(SJSON) installmodule
	$(MAKE) PKG=$(PYMONGO) installmodule
	$(MAKE) installmongodb
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
	mkdir -p $(TMP_DISTU)
	cp -r $(DISTUTILS) $(TMP_DISTU)
	# SuSE prevents installation of modules to private locations
	rm -f /tmp/temp_distutils/distutils/distutils.cfg
	# No longer...


installmodule:
	( cd $(PKG) ; \
	  export PYTHONPATH=$$PYTHONPATH:$(DESTDIR)$(OMD_ROOT)/lib/python ; \
	  export PYTHONPATH=$$PYTHONPATH:$(shell pwd)/../python/tmp.python27/lib/python2.7 ; \
	  export PYTHONPATH=$$PYTHONPATH:$(shell pwd)/../python-modules/tmp.python/lib/python2.7 ; \
	  export LDFLAGS="-L$(shell pwd)/../python/tmp.python27/lib -L$(shell pwd)/../python/tmp.python27/lib/python2.7/config" ; \
	  $(PYTHON) setup.py install \
		--prefix="" \
		--home=$(DESTDIR)$(OMD_ROOT) \
		--install-platlib=$(LOCALPYTHONDIR) \
		--install-purelib=$(LOCALPYTHONDIR) \
		--install-scripts=$(DESTDIR)$(OMD_ROOT)/tmp \
		--install-data=$(DESTDIR)$(OMD_ROOT)/tmp )


installmongodb:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(MONGODB)/bin/mongod $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(MONGODB)/bin/mongo  $(DESTDIR)$(OMD_ROOT)/bin


clean:
	rm -rf $(SHINKEN)
	rm -rf $(PYRO)
	rm -rf $(SJSON)
	rm -rf $(PYMONGO)
	rm -rf $(MONGODB)
