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

# use local chromium if enabled in distro file (by adding chrome dependency)
#ifneq (,$(findstring chromium,$(OS_PACKAGES)))
#  export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
#  export PUPPETEER_EXECUTABLE_PATH=$(shell which chromium-browser chromium 2>/dev/null | head -n 1)
#else
#  export PUPPETEER_DOWNLOAD_PATH=$(shell pwd)/.local-chromium
#  # newer puppeteer versions use this folder
#  export PUPPETEER_CACHE_DIR=$(shell pwd)/.local-chromium
#endif

## puppeteer is currently broken on rhel9 with chromium 134, but only on x86
#ifeq ($(DISTRO_CODE),el9)
#ifeq ($(shell uname -m),x86_64)
#  export PUPPETEER_EXECUTABLE_PATH=
#  unexport PUPPETEER_SKIP_CHROMIUM_DOWNLOAD
#  unexport PUPPETEER_EXECUTABLE_PATH
#  export PUPPETEER_DOWNLOAD_PATH=$(shell pwd)/.local-chromium
#  export PUPPETEER_CACHE_DIR=$(shell pwd)/.local-chromium
#endif
#endif

# skip generic download, we want a specific chrome version
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export PUPPETEER_CACHE_DIR=$(shell pwd)/.local-chromium
export PUPPETEER_DOWNLOAD_PATH=$(shell pwd)/.local-chromium

.PHONY: skel

build:
	echo "module.exports = {}" > .puppeteerrc.cjs # install.sh trys to open .config/.puppeteerrc otherwise
	mkdir -p node_modules
	$(NPM) i progress
	$(NPM) i fix-esm
	$(NPM) i puppeteer$(PUPPETEER)
	rm -rf node_modules/puppeteer/.local-chromium
	rm -rf $(PUPPETEER_DOWNLOAD_PATH)
	$(NPX) @puppeteer/browsers install chrome@$(CHROMIUM_VERSION)
	mkdir -p node_modules/puppeteer/.local-chromium
	mv chrome node_modules/puppeteer/.local-chromium/
	#	cp -rp $(PUPPETEER_DOWNLOAD_PATH) node_modules/puppeteer/.local-chromium; \
	#if [ "x$(PUPPETEER_DOWNLOAD_PATH)" != "x" ]; then \
	#	echo "downloaded chromium along with puppeteer"; \
	#	rm -rf node_modules/puppeteer/.local-chromium; \
	#	cp -rp $(PUPPETEER_DOWNLOAD_PATH) node_modules/puppeteer/.local-chromium; \
	#	rm -rf $(PUPPETEER_DOWNLOAD_PATH); \
	#else \
	#	echo "using system chromium from $(PUPPETEER_EXECUTABLE_PATH)"; \
	#fi

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

