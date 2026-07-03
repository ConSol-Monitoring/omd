include ../../Makefile.omd

NAME=coshsh
CHANGELOG = https://github.com/lausser/coshsh/blob/master/Changelog
VERSION=13.0
COSHSH=$(NAME)-$(VERSION)

build:
	tar xzf $(COSHSH).tar.gz --no-same-owner
	cd $(COSHSH) && \
	    export PYTHONPATH=$(shell pwd)/../python-modules/dest ; \
	    python3 setup.py build

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/python
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/coshsh/recipes/default/classes
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/coshsh/recipes/default/templates
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/coshsh/contrib
	mkdir -p $(DESTDIR)$(OMD_ROOT)/var/coshsh
	cd $(COSHSH) && \
	    export PYTHONPATH=$(shell pwd)/../python-modules/dest ; \
	    python3 setup.py install \
		--root=$(DESTDIR)$(OMD_ROOT) \
		--prefix=/ \
		--install-platlib=/lib/python \
		--install-purelib=/lib/python \
		--install-scripts=/bin \
		--install-data=/share/coshsh
	python3 -c "import sys; exit(0 if sys.version_info >= (3,8) else 1)" && \
	    rm -f $(DESTDIR)$(OMD_ROOT)/lib/python/coshsh_pycompat.py
	cp datasource_snmptt.py \
	    $(DESTDIR)$(OMD_ROOT)/share/coshsh/recipes/default/classes
	cp datarecipient_atomic.py \
	    $(DESTDIR)$(OMD_ROOT)/share/coshsh/recipes/default/classes
	cp datarecipient_prometheus_sd_files.py \
	    $(DESTDIR)$(OMD_ROOT)/share/coshsh/recipes/default/classes
	cp datasource_segen.py \
	    $(DESTDIR)$(OMD_ROOT)/share/coshsh/recipes/default/classes
	cp datarecipient_segen.py \
	    $(DESTDIR)$(OMD_ROOT)/share/coshsh/recipes/default/classes
	cp app_snmptrapdlog.py \
	    $(DESTDIR)$(OMD_ROOT)/share/coshsh/recipes/default/classes
	cp app_snmp_agent.py \
	    $(DESTDIR)$(OMD_ROOT)/share/coshsh/recipes/default/classes
	cp app_snmptrapdlog_default.tpl \
	    $(DESTDIR)$(OMD_ROOT)/share/coshsh/recipes/default/templates
	cp common_traps.tpl \
	    $(DESTDIR)$(OMD_ROOT)/share/coshsh/recipes/default/templates
	cp check_logfiles_snmptt.tpl \
	    $(DESTDIR)$(OMD_ROOT)/share/coshsh/recipes/default/templates
	cp app_snmp_agent_traps.tpl \
	    $(DESTDIR)$(OMD_ROOT)/share/coshsh/recipes/default/templates
	cp snmp_exporter.tpl \
	    $(DESTDIR)$(OMD_ROOT)/share/coshsh/recipes/default/templates
	cp check_git_updates \
	    $(DESTDIR)$(OMD_ROOT)/bin
	chmod 755 $(DESTDIR)$(OMD_ROOT)/bin/check_git_updates
	cp check_snex_updates \
	    $(DESTDIR)$(OMD_ROOT)/bin
	chmod 755 $(DESTDIR)$(OMD_ROOT)/bin/check_snex_updates
	cp coshsh-prepare-landscape \
	    $(DESTDIR)$(OMD_ROOT)/share/coshsh/contrib
	chmod 755 $(DESTDIR)$(OMD_ROOT)/share/coshsh/contrib/coshsh-prepare-landscape
	cp consol_commands.cfg \
	    $(DESTDIR)$(OMD_ROOT)/share/coshsh/contrib
	cp backend-pnp4nagios.cfg \
	    $(DESTDIR)$(OMD_ROOT)/share/coshsh/contrib
	cp coshsh_snmp_exporter.yml \
	    $(DESTDIR)$(OMD_ROOT)/share/coshsh/contrib


skel:

clean:
	rm -rf $(COSHSH)
