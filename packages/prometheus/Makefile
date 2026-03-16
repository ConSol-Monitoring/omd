include ../../Makefile.omd

.PHONY: skel

NAME       = prometheus
CHANGELOG  = https://github.com/prometheus/prometheus/blob/main/CHANGELOG.md
VERSION    = 3.5.1
BRANCH     = master
DIR        = $(NAME)-$(VERSION)
SRC        = $(DIR).tar.xz
GOPKG      = 1.26
GOVERSION  = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
PWD        = $(shell pwd)
GOFOLDER   = go
GOPATH     = /dev/null # should not be used on vendor build
GOROOT     = $(PWD)/../go-$(GOPKG)/go-$(GOVERSION)
DATE       = $(shell TZ=UTC date -u '+%FT%TZ')
NODEPATH   = $(shell ls -d1 ../node/node-v20*/bin)
LDFLAGS    = "\
-X github.com/prometheus/common/version.Version=$(VERSION) \
-X github.com/prometheus/common/version.Revision=release-tar-ball \
-X github.com/prometheus/common/version.Branch=$(BRANCH) \
-X github.com/prometheus/common/version.BuildUser=OMD-Labs \
-X github.com/prometheus/common/version.BuildDate=$(DATE) \
-s -w \
"

build:
	tar xfJ $(SRC)
	mkdir -p $(DIR)/build
	cd $(DIR) && \
		$(GOROOT)/bin/go build -a -tags netgo,builtinassets -trimpath -ldflags $(LDFLAGS) -o build/prometheus -mod=vendor github.com/prometheus/prometheus/cmd/prometheus
	cd $(DIR) && \
		$(GOROOT)/bin/go build -a -tags netgo -trimpath -ldflags $(LDFLAGS) -o build/promtool -mod=vendor github.com/prometheus/prometheus/cmd/promtool
	mkdir -p ./dest/bin/
	install -m 755 $(DIR)/build/prometheus ./dest/bin/
	install -m 755 $(DIR)/build/promtool   ./dest/bin/
	strip dest/bin/*
	$(UPX) ./dest/bin/*
	rm -rf $(DIR)

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 ./dest/bin/* $(DESTDIR)$(OMD_ROOT)/bin

skel:
	mkdir -p $(SKEL)/etc/prometheus
	mkdir -p $(SKEL)/etc/prometheus/conf.d/custom
	echo "Use this dir for your hand-crafted configs." > $(SKEL)/etc/prometheus/conf.d/custom/README
	mkdir -p $(SKEL)/etc/prometheus/conf.d/dynamic
	echo "Use this dir for your automatically created configs. Use coshsh" > $(SKEL)/etc/prometheus/conf.d/dynamic/README

clean:
	rm -rf $(DIR)
	[ ! -e $(GOFOLDER) ] || chmod -R 777 $(GOFOLDER)
	rm -rf $(GOFOLDER)
	rm -rf ./dest/

package: clean
	curl -fLo $(DIR).tar.gz https://github.com/prometheus/prometheus/archive/v$(VERSION).tar.gz
	tar xf $(DIR).tar.gz
	rm -f $(DIR).tar.gz
	cd $(DIR)/web/ui && env PATH=$(NODEPATH):$(GOROOT)/bin:$(PATH) npm install
	cd $(DIR)        && env PATH=$(NODEPATH):$(GOROOT)/bin:$(PATH) make assets npm_licenses assets-compress
	cd $(DIR)/web/ui && rm -r node_modules react-app/node_modules
	cd $(DIR)        && env PATH=$(GOROOT)/bin:$(PATH) go mod vendor
	# remove some heavy but unused files to reduce the tarball size
	find $(DIR)/tsdb -type d -name testdata | xargs -r rm -rf
	XZ_OPT=-8 tar cfJ $(SRC) $(DIR)
	rm -rf $(DIR)

upstream: package
