include ../../Makefile.omd

PYTHON=python3
ANSIBLE_VERSION=2.14.1
ANSIBLE=ansible-$(ANSIBLE_VERSION)
LOCALPYTHONDIR=$(OMD_ROOT)/lib/python
SCRIPT_PATH=$(OMD_ROOT)/bin


build:
	( gzip -d < $(ANSIBLE).tar.gz | tar xf - )
	( cd $(ANSIBLE) ; $(PYTHON) setup.py build )

install:
	mkdir -p $(DESTDIR)/$(LOCALPYTHONDIR)
	export PYTHONPATH=$(LOCALPYTHONDIR); \
	cd $(ANSIBLE) ; $(PYTHON) setup.py  install \
		--home=$(OMD_ROOT) \
		--root=$(DESTDIR) \
		--prefix='' \
		--install-purelib=$(LOCALPYTHONDIR) \
		--install-platlib=$(LOCALPYTHONDIR) \
		--install-scripts=$(SCRIPT_PATH) \
		--install-data=$(OMD_ROOT)/tmp
	if [ $(PYTHON) = python2 ] ; then \
	    install -D -m 755 ansible_wrapper $(DESTDIR)/$(SCRIPT_PATH)/ansible_wrapper && \
	    ln -s $(SCRIPT_PATH)/ansible_wrapper $(DESTDIR)/$(OMD_ROOT)/bin/ansible && \
	    ln -s $(SCRIPT_PATH)/ansible_wrapper $(DESTDIR)/$(OMD_ROOT)/bin/ansible-config && \
	    ln -s $(SCRIPT_PATH)/ansible_wrapper $(DESTDIR)/$(OMD_ROOT)/bin/ansible-connection && \
	    ln -s $(SCRIPT_PATH)/ansible_wrapper $(DESTDIR)/$(OMD_ROOT)/bin/ansible-console && \
	    ln -s $(SCRIPT_PATH)/ansible_wrapper $(DESTDIR)/$(OMD_ROOT)/bin/ansible-doc && \
	    ln -s $(SCRIPT_PATH)/ansible_wrapper $(DESTDIR)/$(OMD_ROOT)/bin/ansible-galaxy && \
	    ln -s $(SCRIPT_PATH)/ansible_wrapper $(DESTDIR)/$(OMD_ROOT)/bin/ansible-inventory && \
	    ln -s $(SCRIPT_PATH)/ansible_wrapper $(DESTDIR)/$(OMD_ROOT)/bin/ansible-playbook && \
	    ln -s $(SCRIPT_PATH)/ansible_wrapper $(DESTDIR)/$(OMD_ROOT)/bin/ansible-pull && \
	    ln -s $(SCRIPT_PATH)/ansible_wrapper $(DESTDIR)/$(OMD_ROOT)/bin/ansible-test && \
	    ln -s $(SCRIPT_PATH)/ansible_wrapper $(DESTDIR)/$(OMD_ROOT)/bin/ansible-vault ; \
	fi
skel:

clean:
	rm -rf ansible-*/

tarball:
	wget -O $(ANSIBLE).tar.gz https://github.com/ansible/ansible/archive/v$(ANSIBLE_VERSION).tar.gz
