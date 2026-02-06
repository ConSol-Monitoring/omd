include ../../Makefile.omd
#Downloadlink for tars: https://golang.org/dl/
NAME         = go
VERSION      = 1.25.7
PACKAGE_ROOT = $(shell cd .. && pwd)
DIR          = $(NAME)-$(VERSION)

ifneq ("$(shell ls -d1 $(PACKAGE_ROOT)/go-1.23/go-1.23*/bin 2>/dev/null)","")
export GOROOT_BOOTSTRAP=$(shell ls -d1 $(PACKAGE_ROOT)/go-1.23/go-1.23*/)
endif

build: clean
	mkdir -p $(DIR)
	tar xzf go$(VERSION).src.tar.gz -C $(DIR)
	mv $(DIR)/go/* $(DIR) && rm -rf $(DIR)/go
	export GOFLAGS="-buildvcs=false" && cd $(DIR)/src/ && ./make.bash
	export GOBIN="$(shell pwd)/." && export PATH=$(shell pwd)/$(DIR)/bin:$$PATH && $(shell pwd)/$(DIR)/bin/go install golang.org/x/vuln/cmd/govulncheck@latest

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 ./govulncheck $(DESTDIR)$(OMD_ROOT)/bin

skel:

clean:
	rm -rf $(DIR)
	rm -f govulncheck

upstream:
	$(MAKE) clean
	rm -f *.gz
	wget "https://go.dev/dl/go$(VERSION).src.tar.gz"
