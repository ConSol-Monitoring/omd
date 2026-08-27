include ../../Makefile.omd

NAME     = node
DIR      = node_modules
SHELL    = /bin/bash
DEPENDS  = node

PUPPETEER=@latest # use latest version by default
CHROMIUM_VERSION=147
ifeq ($(DISTRO_CODE),el7)
  PUPPETEER=@21.11.0 # last version with node 16 support which is required for rhel7
  CHROMIUM_VERSION=121
endif

NODE_PATH=$(shell realpath $$(ls -d1 ../node/node-v*/lib/node_modules/npm/node_modules)):$(shell pwd)/node_modules
NPM=NODE_PATH=$(NODE_PATH) PATH=$(shell realpath $$(ls -d1 ../node/node-v*/bin)):$$PATH npm
NPX=NODE_PATH=$(NODE_PATH) PATH=$(shell realpath $$(ls -d1 ../node/node-v*/bin)):$$PATH npx

# prevents hanging npm install
export UV_USE_IO_URING := 0

# skip generic download, we want a specific chrome version
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export PUPPETEER_CACHE_DIR=$(shell pwd)/.local-chromium
export PUPPETEER_DOWNLOAD_PATH=$(shell pwd)/.local-chromium

# puppeteer downloads an unusable x86 binary on arm, so on arm we must use the system chrome
ifeq ($(shell uname -m),aarch64)
  unexport PUPPETEER_CACHE_DIR
  unexport PUPPETEER_DOWNLOAD_PATH
  export PUPPETEER_EXECUTABLE_PATH=$(shell which chromium-browser chromium 2>/dev/null | head -n 1)
endif

.PHONY: skel

build:
	echo "module.exports = {}" > .puppeteerrc.cjs # install.sh trys to open .config/.puppeteerrc otherwise
	mkdir -p node_modules
	$(NPM) i progress
	$(NPM) i fix-esm
	$(NPM) i puppeteer$(PUPPETEER)
	if [ "x$(PUPPETEER_EXECUTABLE_PATH)" != "x" ]; then \
		echo "using system chromium from $(PUPPETEER_EXECUTABLE_PATH)"; \
	else \
		echo "installing chromium v$(CHROMIUM_VERSION)"; \
		rm -rf node_modules/puppeteer/.local-chromium; \
		rm -rf $(PUPPETEER_DOWNLOAD_PATH); \
		$(NPX) @puppeteer/browsers install chrome@$(CHROMIUM_VERSION); \
		mkdir -p node_modules/puppeteer/.local-chromium; \
		mv chrome node_modules/puppeteer/.local-chromium/; \
	fi
	-$(NPM) audit fix

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/node_modules
	rsync -a node_modules/. $(DESTDIR)$(OMD_ROOT)/lib/node_modules/.

skel:
	mkdir -p $(SKEL)/etc/profile.d
	if [ "x$(PUPPETEER_EXECUTABLE_PATH)" != "x" ]; then \
		echo "export PUPPETEER_EXECUTABLE_PATH=$(PUPPETEER_EXECUTABLE_PATH)" >> $(SKEL)/etc/profile.d/puppeteer.sh; \
	else \
		CHROME=$$(ls -1 node_modules/puppeteer/.local-chromium/chrome/*/chrome-linux*/chrome); \
		test -n "$${CHROME}" || exit 1 ; \
		echo "export PUPPETEER_EXECUTABLE_PATH=./lib/$${CHROME}" >> $(SKEL)/etc/profile.d/puppeteer.sh; \
	fi

clean:
	rm -rf $(DIR)
	rm -f package.json
	rm -f package-lock.json
	rm -f skel/etc/profile.d/puppeteer.sh
	rm -rf .local-chromium
	rm -f .puppeteerrc.cjs

