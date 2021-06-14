include ../../Makefile.omd

NAME       = victoriametrics
PWD        = $(shell pwd)

#for binary downloads
VERSION    = 1.61.1
VVERSION=v$(VERSION)

# for vmctl build
# VMCTL_GIT_TAG: TODO: still set manually for new master version in git repo main.go! no release/version Branches, and adapation in main.go!
GITBASE     = github.com/VictoriaMetrics
VM_SRC      = VictoriaMetrics-$(VVERSION).tar.gz
VMCTL_GITURL      = $(GITBASE)/vmctl
VMCTL_GIT_TAG     = 0.4.0
VMCTL_SRC         = vmctl-$(VMCTL_GIT_TAG).tar.gz
GOPKG       = 1.16
GOVERSION   = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
GOPATH      = $(PWD)/go
GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION)/
PKG_PREFIX=github.com/VictoriaMetrics/VictoriaMetrics
GO_BUILDINFO = -X '$(PKG_PREFIX)/lib/buildinfo.Version=$(APP_NAME)-$(shell date -u +'%Y%m%d-%H%M%S')-$(VVERSION)-omd-$(OMD_VERSION)'

VMCTL_BUILD_CONSTS = \
        -X main.buildTime=`date -u '+%Y-%m-%d_%H:%M:%S'` \
        -X main.buildRevision=omd-build \
        -X main.buildTag=$(VMCTL_GIT_TAG)

VMCTL_BUILD_OPTS = -ldflags="$(VMCTL_BUILD_CONSTS)" -gcflags="-trimpath=$(GOPATH)/src"



APPS = \
        victoria-metrics \
        vmagent \
        vmalert \
        vmauth \
        vmbackup \
        vmrestore

.PHONY: skel

build-app:
	cd VictoriaMetrics-$(VERSION) && \
	  https_proxy=http://127.7.7.7:50000 http_proxy=http://127.7.7.7:50000 \
	  $(GOROOT)/bin/go build -mod=vendor -trimpath -ldflags "-extldflags '-static' $(GO_BUILDINFO)" -tags 'netgo osusergo nethttpomithttp2' \
	  -o bin/$(APP_NAME)-prod $(PKG_PREFIX)/app/$(APP_NAME)

install-app:
	install -m 755 VictoriaMetrics-$(VERSION)/bin/$(APP_NAME)-prod $(DESTDIR)$(OMD_ROOT)/bin

build-vmctl:
	tar zxf $(VMCTL_SRC)
	cd vmctl-$(VMCTL_GIT_TAG)&& https_proxy=http://127.7.7.7:50000 http_proxy=http://127.7.7.7:50000 \
	  $(GOROOT)/bin/go build $(VMCTL_BUILD_OPTS) -mod=vendor -o bin/vmctl

build: build-vmctl
	tar xf $(VM_SRC)
	for i in $(APPS) ; do \
	make build-app APP_NAME=$${i} || exit 1; \
	done

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	for i in $(APPS); do \
	make install-app APP_NAME=$${i} || exit 1; \
	done
	install -m 756 vmctl-$(VMCTL_GIT_TAG)/bin/vmctl $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 *cron* $(DESTDIR)$(OMD_ROOT)/bin

skel:

clean:
	rm -rf $(GOPATH)
	rm -rf VictoriaMetrics-$(VERSION)
	rm -rf vmctl-$(VMCTL_GIT_TAG)

package: clean
	curl -fL -o $(VMCTL_SRC) https://$(GITBASE)/vmctl/archive/$(VMCTL_GIT_TAG).tar.gz
	curl -fL -o $(VM_SRC) https://$(GITBASE)/VictoriaMetrics/archive/$(VVERSION).tar.gz
