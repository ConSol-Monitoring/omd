include ../../Makefile.omd

ANSIBLE=ansible-1.9.5

# This is where the python modules are going to be installed to
LOCALPYTHONDIR=$(DESTDIR)$(OMD_ROOT)/lib/python


build:
	( tar xzf $(ANSIBLE).tar.gz )
	( cd $(ANSIBLE) ; python setup.py build )

install:
	mkdir -p $(LOCALPYTHONDIR)
	export PYTHONPATH=$$PYTHONPATH:$(LOCALPYTHONDIR); \
	cd $(ANSIBLE) ; python setup.py install \
		--home=$(DESTDIR)$(OMD_ROOT) \
		--prefix='' \
		--install-purelib=$(LOCALPYTHONDIR) \
		--install-platlib=$(LOCALPYTHONDIR) \
		--install-scripts=$(DESTDIR)$(OMD_ROOT)/bin \
		--install-data=$(DESTDIR)$(OMD_ROOT)/tmp

skel:

clean:
	rm -rf $(ANSIBLE)
