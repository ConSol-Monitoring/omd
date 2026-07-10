include ../../Makefile.omd

.PHONY: skel

NAME       = prometheus
CHANGELOG  = https://github.com/prometheus/prometheus/blob/main/CHANGELOG.md
VERSION    = 3.13.1
BRANCH     = non-git
DIR        = $(NAME)-$(VERSION)
SRC        = $(DIR).tar.xz
GOPKG      = 1.26
GOVERSION  = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
PWD        = $(shell pwd)
GOFOLDER   = go
GOPATH     = /dev/null # should not be used on vendor build
GOROOT     = $(PWD)/../go-$(GOPKG)/go-$(GOVERSION)
DATE       = $(shell TZ=UTC date -u '+%FT%TZ')
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
	export GOMAXPROCS=2; \
	cd $(DIR) && \
		$(GOROOT)/bin/go build -p=1 -a -tags netgo,builtinassets -trimpath -ldflags $(LDFLAGS) -o build/prometheus -mod=vendor github.com/prometheus/prometheus/cmd/prometheus
	export GOMAXPROCS=2; \
	cd $(DIR) && \
		$(GOROOT)/bin/go build -p=1 -a -tags netgo -trimpath -ldflags $(LDFLAGS) -o build/promtool -mod=vendor github.com/prometheus/prometheus/cmd/promtool
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
	curl -fLo $(DIR)-webui.tar.gz https://github.com/prometheus/prometheus/releases/download/v$(VERSION)/prometheus-web-ui-$(VERSION).tar.gz
	tar xzf $(DIR).tar.gz
	tar -C $(DIR)/web/ui -xzf $(DIR)-webui.tar.gz
	rm -f $(DIR).tar.gz
	rm -f $(DIR)-webui.tar.gz
	cd $(DIR)        && env PATH=$(GOROOT)/bin:$(PATH) go work vendor
	cd $(DIR)        && env PATH=$(GOROOT)/bin:$(PATH) make assets-compress SKIP_UI_BUILD=1
	# remove some heavy but unused files to reduce the tarball size
	find $(DIR)/tsdb -type d -name testdata | xargs -r rm -rf
	XZ_OPT=-8 tar cfJ $(SRC) $(DIR)
	rm -rf $(DIR)

upstream: package
