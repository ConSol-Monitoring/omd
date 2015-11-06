include ../../Makefile.omd

COSHSH=coshsh-3.1

build:
	tar xvzf $(COSHSH).tar.gz
	cd $(COSHSH) && \
	    export PYTHONPATH=$$PYTHONPATH:$(DESTDIR)$(OMD_ROOT)/lib/python ; \
	    python setup.py build

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/python
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/coshsh
	mkdir -p $(DESTDIR)$(OMD_ROOT)/var/coshsh
	cd $(COSHSH) && \
	    export PYTHONPATH=$$PYTHONPATH:$(DESTDIR)$(OMD_ROOT)/lib/python ; \
	    python setup.py install \
	        --home=$(DESTDIR)$(OMD_ROOT) \
                --install-platlib=$(DESTDIR)$(OMD_ROOT)/lib/python \
                --install-purelib=$(DESTDIR)$(OMD_ROOT)/lib/python \
                --install-scripts=$(DESTDIR)$(OMD_ROOT)/bin \
                --install-data=$(DESTDIR)$(OMD_ROOT)/share/coshsh

skel:

clean:
	rm -rf $(COSHSH)
