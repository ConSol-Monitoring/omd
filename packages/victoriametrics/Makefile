include ../../Makefile.omd

NAME       = victoriametrics
PWD        = $(shell pwd)

#for binary downloads
VERSION    = 1.101.0
VVERSION=v$(VERSION)

GITBASE     = github.com/VictoriaMetrics
VM_SRC      = VictoriaMetrics-$(VVERSION).tar.gz
GOPKG       = 1.22
GOVERSION   = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
GOPATH      = $(PWD)/go
GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION)/
PKG_PREFIX=github.com/VictoriaMetrics/VictoriaMetrics
GO_BUILDINFO = -X '$(PKG_PREFIX)/lib/buildinfo.Version=$(APP_NAME)-$(shell date -u +'%Y%m%d-%H%M%S')-$(VVERSION)-omd-$(OMD_VERSION)'

APPS = \
        victoria-metrics \
        vmagent \
        vmalert \
        vmauth \
        vmbackup \
        vmctl \
        vmrestore

.PHONY: skel

build-app:
	cd VictoriaMetrics-$(VERSION) && \
	  https_proxy=http://127.7.7.7:50000 http_proxy=http://127.7.7.7:50000 \
	  PATH=$(GOROOT)/bin:$(PATH) make app-local APP_NAME=$(APP_NAME)

install-app:
	install -m 755 VictoriaMetrics-$(VERSION)/bin/$(APP_NAME) $(DESTDIR)$(OMD_ROOT)/bin/$(APP_NAME)-prod

build:
	tar xf $(VM_SRC)
	for i in $(APPS) ; do \
	make build-app APP_NAME=$${i} || exit 1; \
	done

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	for i in $(APPS); do \
	make install-app APP_NAME=$${i} || exit 1; \
	done
	# historically this is intalled as vmctl
	mv $(DESTDIR)$(OMD_ROOT)/bin/vmctl-prod $(DESTDIR)$(OMD_ROOT)/bin/vmctl
	install -m 755 *cron* $(DESTDIR)$(OMD_ROOT)/bin

skel:
	sed -i -e 's|###APACHE_MODULE_DIR###|$(APACHE_MODULE_DIR)|g' \
	       $(SKEL)/etc/apache/conf.d/victoriametrics.conf

clean:
	rm -rf $(GOPATH)
	rm -rf VictoriaMetrics-$(VERSION)

package: clean
	curl -fL -o $(VM_SRC) https://$(GITBASE)/VictoriaMetrics/archive/$(VVERSION).tar.gz
