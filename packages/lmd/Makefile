include ../../Makefile.omd

NAME        = lmd
#VERSION     = 1.2.0
#BRANCH      = v$(VERSION)
VERSION     = master
BRANCH      = master
SRC         = $(NAME)-$(VERSION).tar.gz
GOPKG       = 1.22
GOVERSION   = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
GOPATH      = go
PWD         = $(shell pwd)
GITBASE     = github.com/sni
GITURL      = $(GITBASE)/$(NAME)
DEPS_SRC    = deps.tar.gz
# GIT TAG is set automatically by "make upstream" or "make package"
GIT_TAG     = v2.2.0

.PHONY: skel

build:
	tar zxf $(DEPS_SRC)
	tar zxf $(SRC)
	export GO111MODULE=auto && \
		export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION)/ && \
		export GOPATH=$(PWD)/$(GOPATH)/ && \
		export PATH=$$GOROOT/bin:$$PATH && \
		go install -ldflags "-s -w -X main.Build=$(OMD_VERSION)-$(GIT_TAG)" $(GITURL)/cmd/lmd

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(PWD)/$(GOPATH)/bin/$(NAME)  $(DESTDIR)$(OMD_ROOT)/bin

skel:

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
		if [ "$(GIT_TAG)" = "$$(git describe --always --tags)" ]; then \
			echo "dependencies already up to date: $(GIT_TAG)"; \
		else \
			find -name \*_test.go -delete && \
			make vendor && \
			cd $(PWD) && \
			tar cf deps.tar --exclude=.git --exclude=*_test.go $(GOPATH)/src/$(GITURL)/vendor && \
			chmod -R 777 $(GOPATH); \
			rm -f $(DEPS_SRC); \
			gzip -9 deps.tar; \
		fi
		rm -rf $(GOPATH)

package: clean
	mkdir -p $(GOPATH)
	export GO111MODULE=auto && \
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		mkdir -p $(GOPATH)/src/$(GITBASE) && \
		cd $(GOPATH)/src/$(GITBASE) && \
		git clone --depth=1 --branch "$(BRANCH)" https://$(GITURL) && \
		cd $(NAME) && \
		if [ "$(GIT_TAG)" = "$$(git describe --always --tags)" ]; then \
			echo "source already up to date: $(GIT_TAG)"; \
		else \
			sed -i $(PWD)/Makefile -e 's/^GIT_TAG.*$$/GIT_TAG     = '$$(git describe --always --tags)'/g' && \
			cd $(PWD) && \
			rm -rf $(GOPATH)/src/$(GITURL)/docs/ && \
			tar cf $(NAME)-$(VERSION).tar --exclude=.git --exclude=docs/ --exclude=*_test.go $(GOPATH)/src/$(GITURL) && \
			chmod -R 777 $(GOPATH); \
			rm -f $(SRC); \
			gzip -9 $(NAME)-$(VERSION).tar; \
		fi
		rm -rf $(GOPATH)

upstream: clean
	$(MAKE) deps
	$(MAKE) package
