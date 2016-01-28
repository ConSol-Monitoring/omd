include ../../Makefile.omd

NAME     = python-modules
VERSION  = $(OMD_VERSION)
DISTRO   = $(shell ../../distro)

MODULES = texttable-0.8.4.tar.gz \
	  pyexcel-io-0.1.0.tar.gz \
	  pyexcel-0.2.0.tar.gz \
	  odfpy-0.9.6.tar.gz \
	  pyexcel-ods-0.1.0.tar.gz \
	  jdcal-1.2.tar.gz \
	  openpyxl-2.2.2.tar.gz \
	  pyexcel-xlsx-0.1.0.tar.gz \
	  MarkupSafe-0.23.tar.gz \
	  Jinja2-2.8.tar.gz


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
	    for M in $(MODULES); do \
		MDIR=$$(echo $$M | sed -e 's/.tar.gz//g' -e 's/.zip//g') ; \
		cd $$MDIR ; \
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
