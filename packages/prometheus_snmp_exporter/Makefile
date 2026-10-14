include ../../Makefile.omd

.PHONY: skel

NAME       = snmp_exporter
VERSION    = 0.21.0
BRANCH     = HEAD
SRC        = v$(VERSION).tar.gz
GOPKG      = 1.27
GOVERSION  = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
PWD        = $(shell pwd)
GOFOLDER   = go
GOPATH     = $(PWD)/go
GOROOT     = $(PWD)/../go-$(GOPKG)/go-$(GOVERSION)
DATE       = $(shell date -u '+%FT%TZ')
LDFLAGS    = "\
-X github.com/prometheus/common/version.Version=$(VERSION)+omd \
-X github.com/prometheus/common/version.Revision=release-tar-ball \
-X github.com/prometheus/common/version.Branch=$(BRANCH) \
-X github.com/prometheus/common/version.BuildUser=OMD-Labs \
-X github.com/prometheus/common/version.BuildDate=$(DATE) \
-s -w \
"

export GOPATH
export GOFLAGS = -modcacherw
export GOTOOLCHAIN = local

build:
	tar zxf $(SRC)
	mkdir -p $(NAME)-$(VERSION)/build
	set -e ; for p in patches/*.patch ; do \
		echo "applying $$p..." ; \
		( cd $(NAME)-$(VERSION) ; patch ) < $$p ; \
	done
	cd $(NAME)-$(VERSION) && \
	    $(GOROOT)/bin/go build -trimpath -ldflags $(LDFLAGS) -o build/$(NAME) github.com/prometheus/$(NAME)
	cd $(NAME)-$(VERSION) && \
	    $(GOROOT)/bin/go build -trimpath -ldflags $(LDFLAGS) -o build/generator github.com/prometheus/$(NAME)/generator
	mkdir -p ./dest/bin
	install -m 755 $(NAME)-$(VERSION)/build/$(NAME)   ./dest/bin/
	install -m 755 $(NAME)-$(VERSION)/build/generator ./dest/bin/snmp_exporter_generator
	strip dest/bin/*
	$(UPX) ./dest/bin/*
	cp $(NAME)-$(VERSION)/snmp.yml                ./dest/
	cp $(NAME)-$(VERSION)/generator/generator.yml ./dest/
	rm -rf $(NAME)-$(VERSION)
	rm -rf $(GOPATH)


install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 ./dest/bin/* $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755  create_snmp_scrape_config.py $(DESTDIR)$(OMD_ROOT)/bin/create_snmp_scrape_config
	ln -fs create_snmp_scrape_config $(DESTDIR)$(OMD_ROOT)/bin/create_snmp_scrape_config.py

skel:
	mkdir -p $(SKEL)/etc/prometheus_snmp_exporter/generator $(SKEL)/etc/prometheus_snmp_exporter/config
	cp ./dest/snmp.yml $(SKEL)/etc/prometheus_snmp_exporter/config/
	cp ./dest/generator.yml $(SKEL)/etc/prometheus_snmp_exporter/generator/

clean:
	rm -rf ./dest
	rm -rf $(NAME)-$(VERSION)
	rm -rf $(GOPATH)

package:
	curl -fLo v$(VERSION).tar.gz https://github.com/prometheus/$(NAME)/archive/v$(VERSION).tar.gz
