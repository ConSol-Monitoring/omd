include ../../Makefile.omd
#Downloadlink for tars: https://golang.org/dl/
NAME         = go
VERSION      = 1.5
DIR          = $(NAME)-$(VERSION)
PACKAGE_ROOT = $(shell cd .. && pwd)

build: clean
	mkdir -p $(DIR)
	tar xzf $(DIR)*.tar.gz -C $(DIR)
	mv $(DIR)/go/* $(DIR) && rm -rf $(DIR)/go
	cd $(DIR)/src/ && GOROOT_BOOTSTRAP=$(PACKAGE_ROOT)/go-1.4/go-1.4 ./make.bash

install:

skel:

clean:
	rm -rf $(DIR)
