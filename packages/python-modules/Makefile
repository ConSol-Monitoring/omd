include ../../Makefile.omd

NAME     = python-modules
VERSION  = $(OMD_VERSION)
DISTRO   = $(shell ../../distro)

MODULES = $(shell cd src; ls *.tar.gz *.zip; cd ..)

build:
	mkdir -p dest
	cd dest && \
	    for M in $(MODULES); do \
		if echo $$M | grep .tar.gz; then \
		    tar xvzf ../src/$$M ; \
		else \
		    unzip -o ../src/$$M ; \
		fi \
	    done
	
	set -e ; cd dest && \
	    export PYTHONPATH=$$PYTHONPATH:$(DESTDIR)$(OMD_ROOT)/lib/python ; \
	    for M in $$(ls); do \
		cd $$M ; \
	        echo PYTHONBUILD $$M ; \
	        python setup.py build ; \
	        cd .. ; \
	    done

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/python
	cd dest && \
	    export PYTHONPATH=$$PYTHONPATH:$(DESTDIR)$(OMD_ROOT)/lib/python ; \
	    for M in $$(ls); do \
		cd $$M ; \
	        echo PYTHONINSTALL $$M ; \
	        python setup.py install --home=$(DESTDIR)$(OMD_ROOT) \
	            --prefix='' \
	            --install-platlib=$(DESTDIR)$(OMD_ROOT)/lib/python \
	            --install-purelib=$(DESTDIR)$(OMD_ROOT)/lib/python ; \
	        cd .. ; \
	    done

skel:

clean:
	rm -rf dest
