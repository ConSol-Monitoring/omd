include ../../Makefile.omd

ANSIBLE_VERSION=2.8.6
ANSIBLE=ansible-$(ANSIBLE_VERSION)

# This is where the python modules are going to be installed to
LOCALPYTHONDIR=$(OMD_ROOT)/lib/python


build:
	( gzip -d < $(ANSIBLE).tar.gz | tar xf - )
	( cd $(ANSIBLE) ; python2 setup.py build )

install:
	mkdir -p $(DESTDIR)/$(LOCALPYTHONDIR)
	export PYTHONPATH=$$PYTHONPATH:$(LOCALPYTHONDIR); \
	cd $(ANSIBLE) ; python2 setup.py  install \
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
