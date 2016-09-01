include ../../Makefile.omd

DATASCRYER=DataScryer-0.0.3

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

package:
	curl -s https://pypi.python.org/simple/datascryer/ | sed -n 's/.*href="\([^"]*\).*/\1/p' | grep $(DATASCRYER).tar.gz | awk '{print "https://pypi.python.org/simple/datascryer/"$$1}' | xargs -L 1 wget

skel:

clean:
	rm -rf $(DATASCRYER)
