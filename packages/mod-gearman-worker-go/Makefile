include ../../Makefile.omd

NAME        = mod-gearman-worker-go
#VERSION     = 1.2.0
#BRANCH      = v$(VERSION)
VERSION     = master
BRANCH      = master
SRC         = $(NAME)-$(VERSION).tar.gz
GOPKG       = 1.21
GOVERSION   = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
GOPATH      = go
PWD         = $(shell pwd)
GITBASE     = github.com/ConSol
GITURL      = $(GITBASE)/$(NAME)
DEPS_SRC    = deps.tar.gz
# GIT TAG is set automatically by "make upstream" or "make package"
GIT_TAG     = v1.3.7

.PHONY: skel

build:
	tar zxf $(DEPS_SRC)
	tar zxf $(SRC)
	export GO111MODULE=auto && \
		export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION)/ && \
		export GOPATH=$(PWD)/$(GOPATH)/ && \
		export PATH=$$GOROOT/bin:$$PATH && \
		go install -ldflags "-s -w -X main.Build=$(OMD_VERSION)-$(GIT_TAG)" $(GITURL)/cmd/mod_gearman_worker

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 0755 $(PWD)/$(GOPATH)/bin/mod_gearman_worker                  $(DESTDIR)$(OMD_ROOT)/bin/
	install -m 0755 $(PWD)/$(GOPATH)/src/$(GITURL)/mod_gearman_worker_epn.pl $(DESTDIR)$(OMD_ROOT)/bin/

skel:
	cp $(GOPATH)/src/$(GITURL)/worker.cfg $(SKEL)/etc/mod-gearman/worker.cfg
	for p in patches/*.skel_patch ; do \
	    echo "applying $$p..." ; \
	    ( cd $(SKEL) ; patch -p1 ) < $$p || exit 1; \
	done

clean:
	[ ! -e $(GOPATH) ] || chmod -R 777 $(GOPATH)
	rm -rf $(GOPATH)

deps: clean
	mkdir -p $(GOPATH)
	export GO111MODULE=auto && \
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		mkdir -p $(GOPATH)/src/$(GITBASE) && \
		cd $(GOPATH)/src/$(GITBASE) && \
		git clone --depth=1 --branch "$(BRANCH)" https://$(GITURL) && \
		cd $(NAME) && \
		make vendor
		cd $(PWD) && \
		tar zcf $(DEPS_SRC) --exclude=.git --exclude=*_test.go $(GOPATH)/src/$(GITURL)/vendor
		chmod -R 777 $(GOPATH) && \
		rm -rf $(GOPATH)

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
		tar zcf $(SRC) --exclude=.git --exclude=*_test.go $(GOPATH)/src/$(GITURL) && \
		chmod -R 777 $(GOPATH) && \
		rm -rf $(GOPATH)

upstream: clean
	$(MAKE) deps
	$(MAKE) package
