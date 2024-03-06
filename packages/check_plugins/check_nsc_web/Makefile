include ../../../Makefile.omd

NAME        = check_nsc_web
BRANCH      = master
VERSION     = master
SRC         = $(NAME)-$(VERSION).tar.gz
GOPKG       = 1.22
GOVERSION   = $(shell grep ^VERSION ../../go-${GOPKG}/Makefile | awk '{ print $$3 }')
GOPATH      = go
PWD         = $(shell pwd)
GITBASE     = github.com/ConSol-Monitoring
GITURL      = $(GITBASE)/$(NAME)
DEPS_SRC    = deps.tar.gz
# GIT TAG is set automatically by "make upstream" or "make package"
GIT_TAG     = v0.6.3

.PHONY: skel

build:
	tar ozxf $(DEPS_SRC)
	tar ozxf $(SRC)
	export GO111MODULE=auto && \
		export GOROOT=$(PWD)/../../go-$(GOPKG)/go-$(GOVERSION)/ && \
		export GOPATH=$(PWD)/$(GOPATH)/ && \
		export PATH=$$GOROOT/bin:$$PATH && \
		go install -ldflags "-s -w -X main.Build=$(OMD_VERSION)-$(GIT_TAG)" $(GITURL)/cmd/$(NAME) && \
		mv $(GOPATH)/bin/$(NAME) .
	chmod -R 777 $(GOPATH)
	rm -rf $(GOPATH)

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins
	install -m 755 ./$(NAME) $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins

skel:

clean:
	[ ! -e $(GOPATH) ] || chmod -R 777 $(GOPATH)
	rm -rf $(GOPATH) $(NAME)

deps: clean
	mkdir -p $(GOPATH)
	export GO111MODULE=auto && \
	export GOROOT=$(PWD)/../../go-$(GOPKG)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		mkdir -p $(GOPATH)/src/$(GITBASE) && \
		cd $(GOPATH)/src/$(GITBASE) && \
		git clone --depth=1 --branch "$(BRANCH)" https://$(GITURL) && \
		cd $(NAME) && \
		make vendor
		cd $(PWD) && \
		tar zcf $(DEPS_SRC) --exclude=.git --exclude=*_test.go $(GOPATH)/src/$(GITURL)/vendor && \
		chmod -R 777 $(GOPATH) && \
		rm -rf $(GOPATH)

package: clean
	mkdir -p $(GOPATH)
	export GO111MODULE=auto && \
	export GOROOT=$(PWD)/../../go-$(GOPKG)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		mkdir -p $(GOPATH)/src/$(GITBASE) && \
		cd $(GOPATH)/src/$(GITBASE) && \
		git clone --depth=1 --branch "$(BRANCH)" https://$(GITURL) && \
		cd $(NAME) && \
		sed -i $(PWD)/Makefile -e 's/^GIT_TAG.*$$/GIT_TAG     = '$$(git describe --always --tags)'/g' && \
		cd $(PWD) && \
		tar zcf $(SRC) --exclude=.git --exclude=*_test.go $(GOPATH)/src/$(GITURL) && \
		chmod -R 777 $(GOPATH) && \
		rm -rf $(GOPATH)

upstream: clean
	$(MAKE) deps
	$(MAKE) package
