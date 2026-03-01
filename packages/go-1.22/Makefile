include ../../Makefile.omd
#Downloadlink for tars: https://golang.org/dl/
NAME         = go
VERSION      = 1.22.10
PACKAGE_ROOT = $(shell cd .. && pwd)
DIR          = $(NAME)-$(VERSION)

ifneq ("$(shell ls -d1 $(PACKAGE_ROOT)/go-1.21/go-1.21*/bin 2>/dev/null)","")
export GOROOT_BOOTSTRAP=$(shell ls -d1 $(PACKAGE_ROOT)/go-1.21/go-1.21*/)
endif

# build this go version if no system go is found or system is older than this version
SYSTEM_GO_EXISTS := $(shell test -x /usr/bin/go && echo yes || echo no)
GO=
ifeq ($(SYSTEM_GO_EXISTS),no)
	# No system go found, need to build
	GO=go
else
	SYSTEM_GO_VERSION := $(shell /usr/bin/go version 2>/dev/null | awk '{print $$3}' | sed 's/go//')
	OLDER_VERSION := $(shell printf '%s\n%s\n' "$(SYSTEM_GO_VERSION)" "$(VERSION)" | sort -V | head -n1)
	ifneq ($(OLDER_VERSION),$(VERSION))
		GO=go
	endif
endif

build: $(GO)

go: clean
	mkdir -p $(DIR)
	tar xzf go$(VERSION).src.tar.gz -C $(DIR)
	mv $(DIR)/go/* $(DIR) && rm -rf $(DIR)/go
	export GOFLAGS="-buildvcs=false" && cd $(DIR)/src/ && ./make.bash

install:

skel:

clean:
	rm -rf $(DIR)

upstream:
	$(MAKE) clean
	rm -f *.gz
	wget "https://go.dev/dl/go$(VERSION).src.tar.gz"
