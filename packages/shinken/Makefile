include ../../Makefile.omd


SHINKEN=shinken-0.5.1
SHINKEN_FILE=$(SHINKEN).tar.gz
SHINKEN_URL=http://sourceforge.net/projects/shinken/files/$(SHINKEN_FILE)
#
# Python Remote Objects
PYRO=Pyro-3.11
PYRO_FILE=$(PYRO).tar.gz
PYRO_URL=http://www.xs4all.nl/~irmen/pyro3/download/$(PYRO_FILE)
#
# Python Multiprocessing
MP=multiprocessing-2.6.2.1
MP_FILE=$(MP).tar.gz
MP_URL=http://pypi.python.org/packages/source/m/multiprocessing/$(MP_FILE)
#
# Simple JSON (not included in CentOS' python2.4)
SJSON=simplejson-2.1.2
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
	#set -e ; for p in patches/*.dif ; do \
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
	#test -f $(SQLITE_FILE) || wget $(SQLITE_URL)
	#tar xzf $(SQLITE_FILE)


install:
	rm -rf $(TMP_DISTU)
	mkdir -p $(LOCALPYTHONDIR)
	$(MAKE) installshinken
	$(MAKE) repairdistutils
	$(MAKE) installstools
	$(MAKE) installpyro
	$(MAKE) installmp
	$(MAKE) installjson
	echo "distro is " $(DISTRO_NAME)
	if [ $(DISTRO_NAME) = "CENTOS" ]; then \
		$(MAKE) installctypes; \
	fi
	#$(MAKE) installsqlite
	rm -rf $(TMP_DISTU)


installshinken:
	# bin/shinken-* startfiles
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(SHINKEN)/bin/shinken-arbiter $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(SHINKEN)/bin/shinken-broker $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(SHINKEN)/bin/shinken-scheduler $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(SHINKEN)/bin/shinken-poller $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(SHINKEN)/bin/shinken-reactionner $(DESTDIR)$(OMD_ROOT)/bin

	# shinken py-files
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/shinken
	cp -r $(SHINKEN)/shinken $(DESTDIR)$(OMD_ROOT)/lib/shinken

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



clean:
	rm -rf $(SHINKEN)
	rm -rf $(PYRO)
	rm -rf $(MP)
	rm -rf $(SJSON)
	rm -rf $(STOOLS)
	rm -rf $(CTYPES)
	rm -rf $(SQLITE)
