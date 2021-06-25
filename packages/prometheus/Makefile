include ../../Makefile.omd

.PHONY: skel

NAME       = prometheus
VERSION    = 2.28.0
BRANCH     = master
SRC        = $(NAME)-$(VERSION).tar.gz
GOPKG      = 1.16
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
	tar zxf $(SRC)
	mkdir -p prometheus-$(VERSION)/build
	cd $(NAME)-$(VERSION) && \
		$(GOROOT)/bin/go build -a -tags netgo,builtinassets -trimpath -ldflags $(LDFLAGS) -o build/prometheus -mod=vendor github.com/prometheus/prometheus/cmd/prometheus
	cd $(NAME)-$(VERSION) && \
		$(GOROOT)/bin/go build -a -tags netgo -trimpath -ldflags $(LDFLAGS) -o build/promtool -mod=vendor github.com/prometheus/prometheus/cmd/promtool

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 prometheus-$(VERSION)/build/prometheus $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 prometheus-$(VERSION)/build/promtool $(DESTDIR)$(OMD_ROOT)/bin

skel:
	mkdir -p $(SKEL)/etc/prometheus
	mkdir -p $(SKEL)/etc/prometheus/conf.d/custom
	echo "Use this dir for your hand-crafted configs." > $(SKEL)/etc/prometheus/conf.d/custom/README
	mkdir -p $(SKEL)/etc/prometheus/conf.d/dynamic
	echo "Use this dir for your automatically created configs. Use coshsh" > $(SKEL)/etc/prometheus/conf.d/dynamic/README
	cp -rp $(NAME)-$(VERSION)/consoles $(SKEL)/etc/prometheus
	cp -rp $(NAME)-$(VERSION)/console_libraries $(SKEL)/etc/prometheus
	mv $(SKEL)/etc/prometheus/consoles/index.html.example $(SKEL)/etc/prometheus/consoles/index.html
	sed -ri 's/index.html.example/index.html/g' $(SKEL)/etc/prometheus/console_libraries/menu.lib

	for p in patches/*.skel_patch ; do \
		echo "applying $$p..." ; \
		( cd $(SKEL) ; patch -p1 ) < $$p || exit 1; \
	done

clean:
	rm -rf $(NAME)-$(VERSION)

package: clean
	curl -fLo prometheus-$(VERSION).tar.gz https://github.com/prometheus/prometheus/archive/v$(VERSION).tar.gz
	tar xf prometheus-$(VERSION).tar.gz
	cd prometheus-$(VERSION) && PATH=/opt/node14/bin:$(GOROOT)/bin:$(PATH) make assets && rm -rf web/ui/static/react/ web/ui/react-app/node_modules/
	cd prometheus-$(VERSION) && env PATH=$(GOROOT)/bin:$(PATH) go mod vendor
	tar czf prometheus-$(VERSION).tar.gz prometheus-$(VERSION)
	rm -rf prometheus-$(VERSION)
