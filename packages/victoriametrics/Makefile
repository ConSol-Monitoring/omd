include ../../Makefile.omd

NAME       = victoriametrics
PWD        = $(shell pwd)
SHELL      = bash

#for binary downloads
VERSION    = 1.149.0
VVERSION   = v$(VERSION)
DIR        = VictoriaMetrics-$(VERSION)

GITBASE     = github.com/VictoriaMetrics
VM_SRC      = VictoriaMetrics-$(VVERSION).tar.xz
GOPKG       = 1.26
GOVERSION   = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
GOPATH      = $(PWD)/go
GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION)/
PKG_PREFIX=github.com/VictoriaMetrics/VictoriaMetrics

APPS = \
        victoria-metrics \
        vmagent \
        vmalert \
        vmauth \
        vmbackup \
        vmctl \
        vmrestore

.PHONY: skel

build:
	tar xfJ $(VM_SRC)
	mkdir -p ./dest
	for i in $(APPS) ; do \
	    make build-app APP_NAME=$${i} || exit 1; \
	done
	strip ./dest/*
	$(UPX) ./dest/*
	rm -rf $(GOPATH)
	rm -rf $(DIR)

build-app:
	cd $(DIR) && \
	  https_proxy=http://127.7.7.7:50000 http_proxy=http://127.7.7.7:50000 \
	  CGO_ENABLED=0 \
	  PATH=$(GOROOT)/bin:$(PATH) make app-local \
	    APP_NAME=$(APP_NAME) BUILDINFO_TAG=$(VVERSION)-omd-$(OMD_VERSION) PKG_TAG=
	install -m 755 $(DIR)/bin/$(APP_NAME) dest/$(APP_NAME)-prod

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 dest/* $(DESTDIR)$(OMD_ROOT)/bin
	# historically this is intalled as vmctl
	mv $(DESTDIR)$(OMD_ROOT)/bin/vmctl-prod $(DESTDIR)$(OMD_ROOT)/bin/vmctl
	install -m 755 *cron* $(DESTDIR)$(OMD_ROOT)/bin

skel:
	sed -i -e 's|###APACHE_MODULE_DIR###|$(APACHE_MODULE_DIR)|g' \
	       $(SKEL)/etc/apache/conf.d/victoriametrics.conf

clean:
	rm -rf ./dest
	rm -rf $(GOPATH)
	rm -rf $(DIR)

package: clean
	test -f VictoriaMetrics-$(VERSION).tar.gz || curl -fL -o VictoriaMetrics-$(VERSION).tar.gz https://$(GITBASE)/VictoriaMetrics/archive/$(VVERSION).tar.gz
	# recompress to save some disk space
	tar xfz VictoriaMetrics-$(VERSION).tar.gz
	rm -rf VictoriaMetrics-$(VERSION).tar.gz
	# remove some heavy but unused files to reduce the tarball size
	rm -rf $(DIR)/docs
	sed -i '/docs\/Makefile/d' $(DIR)/Makefile
	find $(DIR)/ -name \*_windows\*.go -delete
	find $(DIR)/ -name \*_darwin\*.go -delete
	find $(DIR)/ -name \*_freebsd\*.go -delete
	find $(DIR)/ -name \*_openbsd\*.go -delete
	find $(DIR)/ -name \*_netbsd\*.go -delete
	find $(DIR)/ -name \*_riscv\*.go -delete
	find $(DIR)/ -name \*_s390x\*.go -delete
	find $(DIR)/ -name \*_ppc64le\*.go -delete
	find $(DIR)/ -name \*_arm.go -delete
	find $(DIR)/ -name \*_386\*.go -delete
	find $(DIR)/ -name \*_loong64\*.go -delete
	find $(DIR)/ -name \*_test.go -delete
	find $(DIR)/ -name VM_logo.zip -delete
	rm -f $(DIR)/vendor/github.com/valyala/gozstd/libzstd_{darwin,freebsd,windows,illumos,ppc64le}*.{go,a}
	rm -f $(DIR)/vendor/github.com/valyala/gozstd/libzstd_*_arm.a
	rm -f $(DIR)/vendor/github.com/valyala/gozstd/libzstd_*_ppc64le.a
	find $(DIR)/ -name storage.replay -delete
	find $(DIR)/ -name README.md -delete
	find $(DIR)/ -name CONTRIBUTING.md -delete
	find $(DIR)/ -name CHANGELOG.md -delete
	XZ_OPT=-8 tar cfJ $(VM_SRC) $(DIR)
	rm -rf $(DIR)

upstream: package
