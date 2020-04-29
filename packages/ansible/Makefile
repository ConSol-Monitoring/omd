include ../../Makefile.omd

PYTHON3_VERSION=$(shell python3 -c 'import sys;print(sys.hexversion)')
# 50659328 is 0x03050000 which represents python 3.5.0
HAS_PYTHON35=$(shell test $(PYTHON3_VERSION) -ge 50659328  && echo 1 || echo 0 )
ifeq ($(HAS_PYTHON35), 1)
PYTHON=python3
else
PYTHON=python2
endif
ANSIBLE_VERSION=2.9.7
ANSIBLE=ansible-$(ANSIBLE_VERSION)

# This is where the python modules are going to be installed to
LOCALPYTHONDIR=$(OMD_ROOT)/lib/python


build:
	( gzip -d < $(ANSIBLE).tar.gz | tar xf - )
	( cd $(ANSIBLE) ; $(PYTHON) setup.py build )

install:
	mkdir -p $(DESTDIR)/$(LOCALPYTHONDIR)
	export PYTHONPATH=$$PYTHONPATH:$(LOCALPYTHONDIR); \
	cd $(ANSIBLE) ; $(PYTHON) setup.py  install \
		--home=$(OMD_ROOT) \
		--root=$(DESTDIR) \
		--prefix='' \
		--install-purelib=$(LOCALPYTHONDIR) \
		--install-platlib=$(LOCALPYTHONDIR) \
		--install-scripts=$(OMD_ROOT)/bin \
		--install-data=$(OMD_ROOT)/tmp

skel:

clean:
	rm -rf ansible-*/

tarball:
	wget -O $(ANSIBLE).tar.gz https://github.com/ansible/ansible/archive/v$(ANSIBLE_VERSION).tar.gz
