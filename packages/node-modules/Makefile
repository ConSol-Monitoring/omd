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
else
export PUPPETEER_DOWNLOAD_PATH=$(shell pwd)/.local-chromium
endif


.PHONY: skel

build:
	echo "module.exports = {}" > .puppeteerrc.cjs # install.sh trys to open .config/.puppeteerrc otherwise
	mkdir -p node_modules
	$(NPM) i progress
	$(NPM) i puppeteer
	if [ "x$(PUPPETEER_DOWNLOAD_PATH)" != "x" ]; then \
		rm -rf node_modules/puppeteer/.local-chromium; \
		cp -rp $(PUPPETEER_DOWNLOAD_PATH) node_modules/puppeteer/.local-chromium; \
	fi

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/node_modules
	rsync -a node_modules/. $(DESTDIR)$(OMD_ROOT)/lib/node_modules/.

skel:
	mkdir -p $(SKEL)/etc/profile.d
	if [ "x$(PUPPETEER_EXECUTABLE_PATH)" != "x" ]; then \
		echo "export PUPPETEER_EXECUTABLE_PATH=$(PUPPETEER_EXECUTABLE_PATH)" >> $(SKEL)/etc/profile.d/puppeteer.sh; \
	else \
		echo "export PUPPETEER_EXECUTABLE_PATH=./lib/$(shell ls -1 node_modules/puppeteer/.local-chromium/*/chrome-linux/chrome)" >> $(SKEL)/etc/profile.d/puppeteer.sh; \
	fi

clean:
	rm -rf $(DIR)
	rm -f package.json
	rm -f package-lock.json
	rm -f skel/etc/profile.d/puppeteer.sh
	rm -rf .local-chromium
	rm -f .puppeteerrc.cjs

