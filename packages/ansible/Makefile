include ../../Makefile.omd

PYTHONREL=$(shell python -c "import sys; print '.'.join(map(str, sys.version_info[0:2]))")

ANSIBLE=ansible-1.9.5

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

.PHONY: installansible
.PHONY: repairdistutils

build:
	( tar xzf $(ANSIBLE).tar.gz )
	( cd $(ANSIBLE) ; python setup.py build )

install:
	rm -rf $(TMP_DISTU)
	mkdir -p $(LOCALPYTHONDIR)
	$(MAKE) repairdistutils
	$(MAKE) installansible
	rm -rf $(TMP_DISTU)

repairdistutils:
	mkdir $(TMP_DISTU)
	cp -r $(DISTUTILS) $(TMP_DISTU)
	# SuSE prevents installation of modules to private locations
	rm -f /tmp/temp_distutils/distutils/distutils.cfg
	# No longer...
	#
installansible:
	( cd $(ANSIBLE) ; python setup.py install \
		--home=$(DESTDIR)$(OMD_ROOT) \
		--prefix='' \
		--install-purelib=$(LOCALPYTHONDIR) \
		--install-platlib=$(LOCALPYTHONDIR) \
		--install-scripts=$(DESTDIR)$(OMD_ROOT)/bin \
		--install-data=$(DESTDIR)$(OMD_ROOT)/tmp )

skel:

clean:
	rm -rf $(ANSIBLE)
