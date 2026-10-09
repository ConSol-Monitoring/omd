include ../../../Makefile.omd

NAME        = check_prometheus
CHANGELOG   = https://github.com/ConSol-Monitoring/check_prometheus/blob/master/Changelog.md
BRANCH      = main
VERSION     = main
SRC         = $(NAME)-$(VERSION).tar.xz
GOPKG       = 1.27
GOVERSION   = $(shell grep ^VERSION ../../go-${GOPKG}/Makefile | awk '{ print $$3 }')
GOPATH      = go
GOFLAGS     = -trimpath
PWD         = $(shell pwd)
GITBASE     = github.com/consol-monitoring
GITURL      = $(GITBASE)/$(NAME)
# GIT TAG is set automatically by "make upstream" or "make package"
GIT_TAG     = 0.0.8

.PHONY: skel

build:
	tar xfJ deps-*.tar.xz
	tar xfJ $(SRC)
	mkdir -p $(GOPATH)/src/$(GITURL)/vendor/pkg
	cp -rp $(GOPATH)/src/$(GITURL)/pkg/checker $(GOPATH)/src/$(GITURL)/vendor/pkg/
	mkdir -p $(GOPATH)/src/$(GITURL)/vendor/internal
	cp -rp $(GOPATH)/src/$(GITURL)/internal/helper $(GOPATH)/src/$(GITURL)/vendor/internal/
	cp -rp $(GOPATH)/src/$(GITURL)/internal/mode $(GOPATH)/src/$(GITURL)/vendor/mode/
	export GO111MODULE=auto && \
		export GOROOT=$(PWD)/../../go-$(GOPKG)/go-$(GOVERSION)/ && \
		export GOPATH=$(PWD)/$(GOPATH)/ && \
		export PATH=$$GOROOT/bin:$$PATH && \
		( cd $(GOPATH)/src/$(GITURL)/cmd/check_prometheus && go build -ldflags "-s -w -X main.Build=$(OMD_VERSION)-$(GIT_TAG)" -o $(PWD)/check_prometheus )
	chmod -R 777 $(GOPATH)
	rm -rf $(GOPATH)

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins
	install -m 755 ./$(NAME) $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins

skel:

clean:
	[ ! -e $(GOPATH) ] || chmod -R 777 $(GOPATH)
	rm -rf $(GOPATH)
	rm -rf $(NAME)

deps: clean
	mkdir -p $(GOPATH)
	set -xe ; \
	export GO111MODULE=auto && \
	export GOROOT=$(PWD)/../../go-$(GOPKG)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		mkdir -p $(GOPATH)/src/$(GITBASE) && \
		cd $(GOPATH)/src/$(GITBASE) && \
		git clone --depth=1 --branch "$(BRANCH)" https://$(GITURL) && \
		cd $(NAME) && \
		sed -i '/^toolchain /d' go.mod ./buildtools/go.mod && \
		DEPSFILE="$(PWD)/deps-$$(md5sum go.mod | cut -f 1 -d " ").tar.xz"; \
		if test -e "$$DEPSFILE"; then \
			echo "dependencies already up to date: $(GIT_TAG)"; \
		else \
			make vendor && \
			find -name \*_test.go -delete && \
			cd $(PWD) && \
			rm -rf $(GOPATH)/src/$(GITURL)/vendor/pkg/checker/ ; \
			rm -rf $(GOPATH)/src/$(GITURL)/vendor/internal/*/ ; \
			tar cf deps.tar --exclude=.git --exclude=*_test.go $(GOPATH)/src/$(GITURL)/vendor && \
			chmod -R 777 $(GOPATH); \
			rm -f deps*.tar.xz; \
			xz -9 deps.tar; \
			mv deps.tar.xz $$DEPSFILE; \
		fi
		rm -rf $(GOPATH)

package: clean
	mkdir -p $(GOPATH)
	export GO111MODULE=auto && \
	export GOROOT=$(PWD)/../../go-$(GOPKG)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		mkdir -p $(GOPATH)/src/$(GITBASE) && \
		cd $(GOPATH)/src/$(GITBASE) && \
		git clone --depth=1 --branch "$(BRANCH)" https://$(GITURL) && \
		cd $(NAME) && \
		sed -i '/^toolchain /d' go.mod ./buildtools/go.mod && \
		if [ "$(GIT_TAG)" = "$$(git describe --always --tags)" ]; then \
			echo "source already up to date: $(GIT_TAG)"; \
		else \
			sed -i $(PWD)/Makefile -e 's/^GIT_TAG.*$$/GIT_TAG     = '$$(git describe --always --tags)'/g' && \
			cd $(PWD) && \
			tar cf $(NAME)-$(VERSION).tar --exclude=.git --exclude=*_test.go $(GOPATH)/src/$(GITURL) && \
			chmod -R 777 $(GOPATH); \
			rm -f $(SRC); \
			xz -9 $(NAME)-$(VERSION).tar; \
		fi
		rm -rf $(GOPATH)

upstream: clean
	$(MAKE) deps
	$(MAKE) package
