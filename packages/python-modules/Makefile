include ../../Makefile.omd

NAME     = python-modules
VERSION  = $(OMD_VERSION)
DISTRO   = $(shell ../../distro)

# This is where the python modules are going to be installed to
LOCALPYTHONDIR=$(DESTDIR)$(OMD_ROOT)/lib/python
PYTHONREL=$(shell python -c "import sys; print '.'.join(map(str, sys.version_info[0:2]))")

MODULES = texttable-0.8.4.tar.gz \
          ordereddict-1.1.tar.gz \
          pyexcel-io-0.1.0.tar.gz \
          pyexcel-0.2.0.tar.gz \
          odfpy-0.9.6.tar.gz \
          pyexcel-ods-0.1.0.tar.gz \
          jdcal-1.2.tar.gz \
          openpyxl-2.2.2.tar.gz \
          importlib-1.0.3.zip \
          argparse-1.4.0.tar.gz \
          future-0.15.2.tar.gz \
          xlwt-future-0.8.0.tar.gz \
          xlrd-0.9.4.tar.gz \
          pyexcel-xlsx-0.1.0.tar.gz \
          pyexcel-xls-0.1.0.tar.gz \
          MarkupSafe-0.23.tar.gz \
          Jinja2-2.8.tar.gz \
          wstools-0.4.tar.gz \
          fpconst-0.7.2.tar.gz \
          docutils-0.12.tar.gz \
          SOAPpy-0.12.5.tar.gz \
          PyYAML-3.10.tar.gz \
          ecdsa-0.10.tar.gz \
          gearman-2.0.2.tar.gz \
          six-1.10.0.tar.gz \
          orderedmultidict-0.7.5.tar.gz \
          pyasn1-0.1.4.tar.gz \
          pycrypto-2.6.1.tar.gz \
          paramiko-1.12.2.tar.gz \
          pysnmp-4.2.3.tar.gz \
          pywbem-0.7.0.tar.gz \


build:
	mkdir -p dest
	set -e ; cd dest && \
	    export PYTHONPATH=$$PYTHONPATH:$(LOCALPYTHONDIR); \
	    for M in $(MODULES); do \
	        if echo $$M | grep .tar.gz; then \
	            tar xzf ../src/$$M ; \
	        else \
	            unzip -o ../src/$$M ; \
	        fi; \
	        MDIR=$$(echo $$M | sed -e 's/.tar.gz//g' -e 's/.zip//g') ; \
	        cd $$MDIR; \
	        echo PYTHONBUILD $$M ; \
	        python setup.py build ; \
	        cd .. ; \
	    done

install:
	mkdir -p $(LOCALPYTHONDIR)
	set -e ; cd dest && \
	    export PYTHONPATH=$$PYTHONPATH:$(LOCALPYTHONDIR); \
	    for M in $(MODULES); do \
	        MDIR=$$(echo $$M | sed -e 's/.tar.gz//g' -e 's/.zip//g') ; \
	        MNAME=$$(echo $$MDIR | sed -e 's/\-[0-9\.]*$//g' | tr 'A-Z' 'a-z' ) ; \
	        cd $$MDIR ; \
	        echo PYTHONINSTALL $$M ; \
	        python setup.py install --home=$(DESTDIR)$(OMD_ROOT) \
	            --prefix='' \
	            --install-platlib=$(LOCALPYTHONDIR) \
	            --install-purelib=$(LOCALPYTHONDIR) ; \
	        cd .. ; \
	    done

skel:

clean:
	rm -rf dest
