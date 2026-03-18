include ../../Makefile.omd

NAME         = go
VERSION      = 1.26.1
PACKAGE_ROOT = $(shell cd .. && pwd)
DIR          = $(NAME)-$(VERSION)

export GOROOT_BOOTSTRAP=$(shell ls -d1 $(PACKAGE_ROOT)/go-bootstrap/go/ 2>/dev/null)

build:
	mkdir -p $(DIR)
	tar xfJ go$(VERSION).src.tar.xz -C $(DIR)
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
	rm -f *.xz
	test -f go$(VERSION).src.tar.gz || wget "https://go.dev/dl/go$(VERSION).src.tar.gz"
	tar xfz go$(VERSION).src.tar.gz
	XZ_OPT=-8 tar cfJ go$(VERSION).src.tar.xz go
	rm -rf go
	rm -f *.gz
