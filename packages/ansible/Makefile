include ../../Makefile.omd

PYTHON=python3
ANSIBLE_VERSION=2.9.7
ANSIBLE=ansible-$(ANSIBLE_VERSION)

# This is where the python modules are going to be installed to
LOCALPYTHONDIR=$(OMD_ROOT)/lib/python
SCRIPT_PATH=$(OMD_ROOT)/bin



build:
	( gzip -d < $(ANSIBLE).tar.gz | tar xf - )
	( cd $(ANSIBLE) ; $(PYTHON) setup.py build )

install:
	mkdir -p $(DESTDIR)/$(LOCALPYTHONDIR)
	export PYTHONPATH=$(LOCALPYTHONDIR); \
	cd $(ANSIBLE) ; $(PYTHON) setup.py  install \
		--home=$(OMD_ROOT) \
		--root=$(DESTDIR) \
		--prefix='' \
		--install-purelib=$(LOCALPYTHONDIR) \
		--install-platlib=$(LOCALPYTHONDIR) \
		--install-scripts=$(SCRIPT_PATH) \
		--install-data=$(OMD_ROOT)/tmp
skel:

clean:
	rm -rf ansible-*/

tarball:
	wget -O $(ANSIBLE).tar.gz https://github.com/ansible/ansible/archive/v$(ANSIBLE_VERSION).tar.gz
