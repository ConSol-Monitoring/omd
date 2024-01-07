include ../../Makefile.omd

NAME        = nagflux
VERSION     = master
BRANCH      = master
SRC         = $(NAME)-$(VERSION).tar.gz
GOPKG       = 1.21
GOVERSION   = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
GOPATH      = go
PWD         = $(shell pwd)
CONFIG_FILE = $(DESTDIR)$(OMD_ROOT)/etc/nagflux/config.gcfg
GITBASE     = github.com/ConSol
GITURL      = $(GITBASE)/$(NAME)
DEPS_SRC    = deps.tar.gz
# GIT TAG is set automatically by "make upstream" or "make package"
GIT_TAG     = 5ac49c5

build:
	tar zxf $(DEPS_SRC)
	tar zxf $(SRC)
	export GO111MODULE=auto && \
		export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION)/ && \
		export GOPATH=$(PWD)/$(GOPATH)/ && \
		export PATH=$$GOROOT/bin:$$PATH && \
		go install -ldflags "-s -w -X main.Build=$(OMD_VERSION)-$(GIT_TAG)" $(GITURL)/cmd/nagflux

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(PWD)/$(GOPATH)/bin/nagflux  $(DESTDIR)$(OMD_ROOT)/bin
	mkdir -p $(DESTDIR)$(OMD_ROOT)/var/nagflux
	install -m 755 $(PWD)/migrate_pnp_to_nagflux $(DESTDIR)$(OMD_ROOT)/bin

skel:

clean:
	rm -rf $(GOPATH)

deps: clean
	mkdir -p $(GOPATH)
	export GO111MODULE=auto && \
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		mkdir -p $(GOPATH)/src/$(GITBASE) && \
		cd $(GOPATH)/src/$(GITBASE) && \
		git clone --depth=1 --branch "$(BRANCH)" https://$(GITURL) && \
		go get ./... && \
		cd $(PWD) && \
		rm -rf  $(GOPATH)/src/$(GITBASE)
		tar zcf $(DEPS_SRC) --exclude=.git --exclude=*_test.go $(GOPATH)/src/

package: clean
	mkdir -p $(GOPATH)
	export GO111MODULE=auto && \
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		mkdir -p $(GOPATH)/src/$(GITBASE) && \
		cd $(GOPATH)/src/$(GITBASE) && \
		git clone --depth=1 --branch "$(BRANCH)" https://$(GITURL) && \
		cd $(NAME) && \
		sed -i $(PWD)/Makefile -e 's/^GIT_TAG.*$$/GIT_TAG     = '$$(git describe --always --tags)'/g' && \
		cd $(PWD) && \
		tar zcf $(SRC) --exclude=.git --exclude=*_test.go $(GOPATH)/src/$(GITURL)

upstream: clean deps package
