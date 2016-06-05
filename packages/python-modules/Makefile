include ../../Makefile.omd

NAME     = python-modules
VERSION  = $(OMD_VERSION)
DISTRO   = $(shell ../../distro)
PYTHON   = LD_LIBRARY_PATH=$(shell pwd)/../python/tmp.python27/lib \
	   $(shell pwd)/../python/tmp.python27/bin/python

MODULES =
# Modules really needed on all platforms
MODULES += pysphere-0.1.7.zip
MODULES += pyasn1-0.1.7.tar.gz
MODULES += pycrypto-2.6.1.tar.gz
MODULES += pysnmp-4.2.4.tar.gz

# Modules needed because of own packed python (would be available in OS)
MODULES += setuptools-22.0.5.tar.gz  # needed by rrdtool bindings

LEGACY_LDAP=0
ifeq ($(DISTRO_CODE),el5)
    LEGACY_LDAP=1
endif

ifeq ($(LEGACY_LDAP), 1)
    MODULES += python-ldap-2.3.13.tar.gz
    SKIP_PATCH=patches/0001-python-ldap-2.4.25-disable-sasl.dif
else
    MODULES += python-ldap-2.4.25.tar.gz
    SKIP_PATCH=patches/0001-python-ldap-2.3.13-disable-sasl.dif
endif

build: check-python
	mkdir -p dest
	cd dest && \
	    for M in $(MODULES); do \
		echo "Unpacking $$M..." ; \
		if echo $$M | grep .tar.gz; then \
		    tar xvzf ../src/$$M ; \
		else \
		    unzip -o ../src/$$M ; \
		fi \
	    done
	
	set -e ; for p in patches/*.dif ; do \
	    if [ $$p != $(SKIP_PATCH) ]; then \
	        echo "applying $$p..." ; \
	        ( cd dest ; patch -p1 -b ) < $$p ; \
	    fi ; \
	done
	set -e ; cd dest && \
	    TMP_INSTALL_PATH=$(shell pwd)/tmp.python ; \
	    mkdir $$TMP_INSTALL_PATH/lib || true; \
	    export PYTHONPATH=$$PYTHONPATH:$$TMP_INSTALL_PATH/lib ; \
	    export PYTHONPATH=$$PYTHONPATH:$(DESTDIR)$(OMD_ROOT)/lib/python ; \
	    export PYTHONPATH=$$PYTHONPATH:$(shell pwd)/../python/tmp.python27/lib/python2.7 ; \
	    export LDFLAGS="-L$(shell pwd)/../python/tmp.python27/lib -L$(shell pwd)/../python/tmp.python27/lib/python2.7/config" ; \
	    for M in $$(ls); do \
		echo "Building $$M..." ; \
		cd $$M ; \
	        $(PYTHON) setup.py build ; \
	        $(PYTHON) setup.py install --home=$$TMP_INSTALL_PATH \
	            --prefix='' \
	            --install-platlib=$$TMP_INSTALL_PATH/lib \
	            --install-purelib=$$TMP_INSTALL_PATH/lib ; \
	        cd .. ; \
	    done

check-python:
	@if [ ! -d ../python/tmp.python27 ]; then \
	    echo "ERROR: You need to build the \"python\" package first" ; \
	    exit 1 ; \
	fi

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/python
	cd dest && \
	    export PYTHONPATH=$$PYTHONPATH:$(DESTDIR)$(OMD_ROOT)/lib/python ; \
	    for M in $$(ls); do \
		echo "Installing $$M..." ; \
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
	rm -rf dest tmp.python
