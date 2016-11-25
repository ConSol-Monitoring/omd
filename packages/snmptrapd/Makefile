include ../../Makefile.omd

SAMPLICATOR=samplicator-f4ba263

build:
	tar xvzf $(SAMPLICATOR).tar.gz
	cd $(SAMPLICATOR) && \
	    ./autogen.sh; \
	    ./configure; \
	    mak

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	cd $(COSHSH) && \
	    export PYTHONPATH=$$PYTHONPATH:$(DESTDIR)$(OMD_ROOT)/lib/python ; \
	    python setup.py install \
	        --prefix= \
	        --home=$(DESTDIR)$(OMD_ROOT) \
                --install-platlib=$(DESTDIR)$(OMD_ROOT)/lib/python \
                --install-purelib=$(DESTDIR)$(OMD_ROOT)/lib/python \
                --install-scripts=$(DESTDIR)$(OMD_ROOT)/bin \
                --install-data=$(DESTDIR)$(OMD_ROOT)/share/coshsh
	cp snmptrap_logger.sh \
	    $(DESTDIR)$(OMD_ROOT)/bin

skel:

clean:
	rm -rf $(SAMPLICATOR)
