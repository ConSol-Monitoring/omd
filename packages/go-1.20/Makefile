include ../../Makefile.omd
#Downloadlink for tars: https://golang.org/dl/
NAME         = go
VERSION      = 1.20.5
PACKAGE_ROOT = $(shell cd .. && pwd)
DIR          = $(NAME)-$(VERSION)

ifneq ("$(shell ls -d1 $(PACKAGE_ROOT)/go-1.19/go-1.19*/bin 2>/dev/null)","")
export GOROOT_BOOTSTRAP=$(shell ls -d1 $(PACKAGE_ROOT)/go-1.19/go-1.19*/)
endif

build: clean
	mkdir -p $(DIR)
	tar xzf go$(VERSION).src.tar.gz -C $(DIR)
	mv $(DIR)/go/* $(DIR) && rm -rf $(DIR)/go
	cd $(DIR)/src/ && ./make.bash

install:

skel:

clean:
	rm -rf $(DIR)
