include ../../Makefile.omd

DATASCRYER=dataScryer-0.0.1

build:
	tar xvzf $(DATASCRYER).tar.gz
	cd $(DATASCRYER) && \
	    export PYTHONPATH=$$PYTHONPATH:$(DESTDIR)$(OMD_ROOT)/lib/python ; \
	    python setup.py build

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/python
	cd $(DATASCRYER) && \
	    export PYTHONPATH=$$PYTHONPATH:$(DESTDIR)$(OMD_ROOT)/lib/python ; \
	    python setup.py install \
	        --prefix= \
	        --home=$(DESTDIR)$(OMD_ROOT) \
                --install-platlib=$(DESTDIR)$(OMD_ROOT)/lib/python \
                --install-purelib=$(DESTDIR)$(OMD_ROOT)/lib/python \
                --install-scripts=$(DESTDIR)$(OMD_ROOT)/bin \
                --install-data=$(DESTDIR)$(OMD_ROOT)/share/dataScryer

skel:

clean:
	rm -rf $(DATASCRYER)
