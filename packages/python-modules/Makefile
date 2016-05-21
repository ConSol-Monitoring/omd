include ../../Makefile.omd

NAME     = python-modules
VERSION  = $(OMD_VERSION)
DISTRO   = $(shell ../../distro)
PYTHON   = $(shell realpath $$(pwd)/../python/tmp.python27/bin/python)

MODULES =
# Modules really needed on all platforms
MODULES += pysphere-0.1.7.zip
MODULES += pyasn1-0.1.7.tar.gz
MODULES += pycrypto-2.6.1.tar.gz
MODULES += pysnmp-4.2.4.tar.gz

# Modules needed because of own packed python (would be available in OS)
MODULES += setuptools-22.0.5.tar.gz  # needed by rrdtool bindings
MODULES += python-ldap-2.4.25.tar.gz # used for cmk ldap sync

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
	
	set -e ; for p in patches/*.dif ; do \
	    echo "applying $$p..." ; \
	    ( cd dest ; patch -p1 -b ) < $$p ; \
	done
	
	set -e ; cd dest && \
	    export PYTHONPATH=$$PYTHONPATH:$(DESTDIR)$(OMD_ROOT)/lib/python:$(shell realpath $$(pwd)/../python/tmp.python27/lib/python2.7) ; \
	    env ; \
	    for M in $$(ls); do \
		cd $$M ; \
	        $(PYTHON) setup.py build ; \
	        cd .. ; \
	    done

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/python
	cd dest && \
	    export PYTHONPATH=$$PYTHONPATH:$(DESTDIR)$(OMD_ROOT)/lib/python ; \
	    for M in $$(ls); do \
		cd $$M ; \
	        $(PYTHON) setup.py install --home=$(DESTDIR)$(OMD_ROOT) \
	            --prefix='' \
	            --install-platlib=$(DESTDIR)$(OMD_ROOT)/lib/python \
	            --install-purelib=$(DESTDIR)$(OMD_ROOT)/lib/python ; \
	        cd .. ; \
	    done
	
	# Fix python interpreter for kept scripts
	sed -i "1s|^#!.*python|#!$(OMD_ROOT)/bin/python|" \
	    $(DESTDIR)$(OMD_ROOT)/bin/easy_install \
	    $(DESTDIR)$(OMD_ROOT)/bin/easy_install-2.7 \
	    $(DESTDIR)$(OMD_ROOT)/bin/libsmi2pysnmp

skel:

clean:
	rm -rf dest
