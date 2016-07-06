include ../../Makefile.omd

ANSIBLE_VERSION=2.1.0.0-1
ANSIBLE=ansible-$(ANSIBLE_VERSION)

# This is where the python modules are going to be installed to
LOCALPYTHONDIR=$(OMD_ROOT)/lib/python


build:
	( xz -d < $(ANSIBLE).tar.xz | tar xf - )
	( cd $(ANSIBLE) ; python setup.py build )

install:
	mkdir -p $(DESTDIR)/$(LOCALPYTHONDIR)
	export PYTHONPATH=$$PYTHONPATH:$(LOCALPYTHONDIR); \
	cd $(ANSIBLE) ; python setup.py  install \
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
	./maketarball $(ANSIBLE_VERSION)
