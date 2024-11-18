include ../../Makefile.omd

NAME       = ansible
VERSION    = 2.9.27
SHELL      = /bin/bash
DIR        = $(NAME)-$(VERSION)

DEPENDS    = python-modules

# prefer system ansible if enabled in distro file (by adding ansible-core dependency)
ifneq (,$(findstring ansible,$(OS_PACKAGES)))
  BUILD_DEPS=
  INSTALL_DEPS=
else
  BUILD_DEPS=build-ansible
  INSTALL_DEPS=install-ansible
endif

.PHONY: skel

build: $(BUILD_DEPS)

build-ansible:
	tar zxf $(DIR).tar.gz
	export PYTHONPATH=$(shell pwd)/../python-modules/dest:$$PYTHONPATH; \
		cd $(DIR) && python3 setup.py bdist_wheel
	mkdir -p wheels/
	mv $(DIR)/dist/*.whl wheels/
	rm -rf $(DIR)
	mkdir -p dest/
	export PYTHONPATH=$(shell pwd)/../python-modules/dest:$$PYTHONPATH; \
		python3 -m pip install --no-cache-dir --no-index --no-deps --find-links=wheels/ --target=dest/ --upgrade wheels/*.whl

install: $(INSTALL_DEPS)

install-ansible:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	rsync -a ./dest/bin/. $(DESTDIR)$(OMD_ROOT)/bin/.
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/python
	rsync -a ./dest/ansible* $(DESTDIR)$(OMD_ROOT)/lib/python/

skel:

clean:
	rm -rf $(DIR)
	rm -rf wheels
	rm -rf dest

tarball:
	wget -O $(DIR).tar.gz https://github.com/ansible/ansible/archive/v$(VERSION).tar.gz
