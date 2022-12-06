include ../../Makefile.omd
#Downloadlink for tars: https://golang.org/dl/
NAME         = go
VERSION      = 1.19.3
PACKAGE_ROOT = $(shell cd .. && pwd)
DIR          = $(NAME)-$(VERSION)

ifneq ("$(wildcard $(PACKAGE_ROOT)/go-1.4/go)","")
export GOROOT_BOOTSTRAP=$(PACKAGE_ROOT)/go-1.4/go
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
