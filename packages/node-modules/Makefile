include ../../Makefile.omd

NAME     = node
DIR      = node_modules
SHELL    = /bin/bash
DEPENDS  = node

NODE_PATH=$(shell realpath $$(ls -d1 ../node/node-v*/lib/node_modules/npm/node_modules)):$(shell pwd)/node_modules
NPM=NODE_PATH=$(NODE_PATH) PATH=$(shell realpath $$(ls -d1 ../node/node-v*/bin)):$$PATH npm

.PHONY: skel

build:
	mkdir -p node_modules
	$(NPM) i progress
	$(NPM) i puppeteer

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/node_modules
	rsync -a node_modules/. $(DESTDIR)$(OMD_ROOT)/lib/node_modules/.

skel:

clean:
	rm -rf $(DIR)
	rm -f package.json
	rm -f package-lock.json

