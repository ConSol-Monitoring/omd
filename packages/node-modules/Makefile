include ../../Makefile.omd

NAME     = node
DIR      = node_modules
SHELL    = /bin/bash
DEPENDS  = node

NODE_PATH=$(shell realpath $$(ls -d1 ../node/node-v*/lib/node_modules/npm/node_modules)):$(shell pwd)/node_modules
NPM=NODE_PATH=$(NODE_PATH) PATH=$(shell realpath $$(ls -d1 ../node/node-v*/bin)):$$PATH npm

# use local chromium if enabled in distro file (by adding chrome dependency)
ifneq (,$(findstring chromium,$(OS_PACKAGES)))
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export PUPPETEER_EXECUTABLE_PATH=$(shell which chromium)
endif


.PHONY: skel

build:
	mkdir -p node_modules
	$(NPM) i progress
	$(NPM) i puppeteer

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/node_modules
	rsync -a node_modules/. $(DESTDIR)$(OMD_ROOT)/lib/node_modules/.

skel:
	if [ "x$(PUPPETEER_EXECUTABLE_PATH)" != "x" ]; then \
		mkdir -p $(SKEL)/etc/profile.d; \
		echo "export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true"                   > $(SKEL)/etc/profile.d/puppeteer.sh; \
		echo "export PUPPETEER_EXECUTABLE_PATH=$(PUPPETEER_EXECUTABLE_PATH)" >> $(SKEL)/etc/profile.d/puppeteer.sh; \
	fi

clean:
	rm -rf $(DIR)
	rm -f package.json
	rm -f package-lock.json
	rm -f skel/etc/profile.d/puppeteer.sh

