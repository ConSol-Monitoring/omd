include ../../Makefile.omd

COSHSH=coshsh-3.2.4

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
	        --prefix= \
	        --home=$(DESTDIR)$(OMD_ROOT) \
                --install-platlib=$(DESTDIR)$(OMD_ROOT)/lib/python \
                --install-purelib=$(DESTDIR)$(OMD_ROOT)/lib/python \
                --install-scripts=$(DESTDIR)$(OMD_ROOT)/bin \
                --install-data=$(DESTDIR)$(OMD_ROOT)/share/coshsh
	cp datasource_snmptt.py \
	    $(DESTDIR)$(OMD_ROOT)/share/coshsh/recipes/default/classes
	cp datarecipient_atomic.py \
	    $(DESTDIR)$(OMD_ROOT)/share/coshsh/recipes/default/classes
	cp app_snmptrapdlog.py \
	    $(DESTDIR)$(OMD_ROOT)/share/coshsh/recipes/default/classes
	cp app_snmptrapdlog_default.tpl \
	    $(DESTDIR)$(OMD_ROOT)/share/coshsh/recipes/default/templates
	cp common_traps.tpl \
	    $(DESTDIR)$(OMD_ROOT)/share/coshsh/recipes/default/templates
	cp check_logfiles_snmptt.tpl \
	    $(DESTDIR)$(OMD_ROOT)/share/coshsh/recipes/default/templates

skel:

clean:
	rm -rf $(COSHSH)
