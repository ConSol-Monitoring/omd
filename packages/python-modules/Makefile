include ../../Makefile.omd

NAME     = python-modules
VERSION  = $(OMD_VERSION)
DISTRO   = $(shell ../../distro)

MODULES = pysphere-0.1.7.zip

build:
	mkdir -p dest
	cd dest && \
	    for M in $(MODULES); do \
		unzip -o ../src/$$M ; \
		cd $M ; \
	    done

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/python
	pwd
	cd dest && \
	    export PYTHONPATH=$$PYTHONPATH:$(DESTDIR)$(OMD_ROOT)/lib/python ; \
	    for M in $(shell ls dest); do \
		cd $$M ; \
		python setup.py install --home=$(DESTDIR)$(OMD_ROOT) --prefix='' ; \
		if [ -n "$(DESTDIR)$(OMD_ROOT)" -a -d "$(DESTDIR)$(OMD_ROOT)/lib64" ] ; then mv $(DESTDIR)$(OMD_ROOT)/lib64/* $(DESTDIR)$(OMD_ROOT)/lib; rm -rf $(DESTDIR)$(OMD_ROOT)/lib64 ; fi \
		cd .. ; \
	    done

skel:

clean:
	rm -rf dest
