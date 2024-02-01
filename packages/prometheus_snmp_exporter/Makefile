include ../../Makefile.omd

.PHONY: skel

NAME       = snmp_exporter
VERSION    = consol
BRANCH     = master
SRC        = $(NAME)-$(VERSION).tar.gz
GOPKG      = 1.21
GOVERSION  = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
PWD        = $(shell pwd)
GOFOLDER   = go
GOPATH     = /dev/null
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

build:
	tar zxf $(SRC)
	mkdir -p $(NAME)-$(VERSION)/build
	set -e ; for p in patches/*.patch ; do \
		echo "applying $$p..." ; \
		( cd $(NAME)-$(VERSION) ; patch ) < $$p ; \
	done
	cd $(NAME)-$(VERSION) && \
	    $(GOROOT)/bin/go build -mod=vendor -trimpath -ldflags $(LDFLAGS) -o build/$(NAME) github.com/prometheus/$(NAME)
	cd $(NAME)-$(VERSION) && \
	    $(GOROOT)/bin/go build -mod=vendor -trimpath -ldflags $(LDFLAGS) -o build/generator github.com/prometheus/$(NAME)/generator


install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(NAME)-$(VERSION)/build/$(NAME) $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(NAME)-$(VERSION)/build/generator $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755  create_snmp_scrape_config.py $(DESTDIR)$(OMD_ROOT)/bin/create_snmp_scrape_config
	ln -fs create_snmp_scrape_config $(DESTDIR)$(OMD_ROOT)/bin/create_snmp_scrape_config.py

skel:
	mkdir -p $(SKEL)/etc/prometheus_snmp_exporter/generator $(SKEL)/etc/prometheus_snmp_exporter/config
	cp $(NAME)-$(VERSION)/snmp.yml $(SKEL)/etc/prometheus_snmp_exporter/config/
	cp $(NAME)-$(VERSION)/generator/generator.yml $(SKEL)/etc/prometheus_snmp_exporter/generator/

clean:
	rm -rf $(NAME)-$(VERSION)

package: clean
	curl -fLo $(NAME)-$(VERSION).tar.gz https://github.com/prometheus/$(NAME)/archive/v$(VERSION).tar.gz
	tar xf $(NAME)-$(VERSION).tar.gz
	cd $(NAME)-$(VERSION) && env PATH=$(GOROOT)/bin:$(PATH) go mod vendor
	tar czf $(NAME)-$(VERSION).tar.gz $(NAME)-$(VERSION)
	rm -r $(NAME)-$(VERSION)
