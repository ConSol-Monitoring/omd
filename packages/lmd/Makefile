include ../../Makefile.omd

NAME        = lmd
#VERSION     = 1.2.0
#BRANCH      = v$(VERSION)
VERSION     = master
BRANCH      = master
SRC         = $(NAME)-$(VERSION).tar.gz
GOPKG       = 1.9
GOVERSION   = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
GOPATH      = go
PWD         = $(shell pwd)
GITBASE     = github.com/sni
GITURL      = $(GITBASE)/$(NAME)
DEPS_SRC    = deps.tar.gz

.PHONY: skel

build:
	tar zxf $(DEPS_SRC)
	tar zxf $(SRC)
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
	#go install -ldflags "-s -w -X main.Build=$(OMD_VERSION)_($(shell cd $(PWD)/$(GOPATH)/src/$(GITURL) && git rev-parse --short HEAD))" $(GITURL)/$(NAME)
	go install -ldflags "-s -w -X main.Build=$(OMD_VERSION)" $(GITURL)/$(NAME)

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(PWD)/$(GOPATH)/bin/$(NAME)  $(DESTDIR)$(OMD_ROOT)/bin

skel:

clean:
	rm -rf $(GOPATH)

deps: clean
	mkdir -p $(GOPATH)
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		mkdir -p $(GOPATH)/src/$(GITBASE) && \
		cd $(GOPATH)/src/$(GITBASE) && \
		git clone --depth=1 --branch "$(BRANCH)" https://$(GITURL) && \
		go get ./... && \
		cd $(PWD) && \
		rm -rf  $(GOPATH)/src/$(GITBASE)
		tar zcf $(DEPS_SRC) $(GOPATH)/src/ --exclude=.git --exclude=*_test.go

package: clean deps
	mkdir -p $(GOPATH)
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		mkdir -p $(GOPATH)/src/$(GITBASE) && \
		cd $(GOPATH)/src/$(GITBASE) && \
		git clone --depth=1 --branch "$(BRANCH)" https://$(GITURL) && \
		cd $(PWD) && \
		tar zcf $(SRC) $(GOPATH)/src/$(GITURL) --exclude=.git --exclude=*_test.go

upstream: clean deps package
