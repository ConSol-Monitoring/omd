include ../../Makefile.omd

NAME       = influxdb
VERSION    = 1.8.4
SRC        = $(NAME)-$(VERSION).tar.gz
GOPATH     = go
GOPKG      = 1.16
GOVERSION  = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
GOROOT     = $(PWD)/../go-$(GOPKG)/go-$(GOVERSION)
PWD        = $(shell pwd)
DATE       = $(shell date -u '+%Y-%m-%d_%I:%M:%S%p')

build:
	tar zxf $(SRC)
	set -e ; cd influxdb-$(VERSION); for p in ../patches/*.patch ; do \
	    echo "applying $$p..." ; \
	    patch -p1 < $$p ; \
	done
	cd influxdb-$(VERSION) && \
		env GOPATH=$(PWD)/$(GOPATH)/ PATH=$(GOROOT)/bin:$(PATH) \
		go install -mod vendor -ldflags "-X main.version=$(VERSION) -X main.buildTime=$(DATE) -s -w" ./...

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(PWD)/$(GOPATH)/bin/influx  $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(PWD)/$(GOPATH)/bin/influxd $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(PWD)/$(GOPATH)/bin/influx_inspect $(DESTDIR)$(OMD_ROOT)/bin
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins
	install -m 755 $(PWD)/check_influxdb.pl $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/histou/templates/default/
	install -m 644 $(PWD)/influxdb.simple $(DESTDIR)$(OMD_ROOT)/share/histou/templates/default/influxdb.simple

skel:

clean:
	rm -rf influxdb-$(VERSION) $(PWD)/$(GOPATH)

package: clean
	curl -fLo influxdb-$(VERSION).tar.gz https://github.com/influxdata/influxdb/archive/v$(VERSION).tar.gz
	tar xf influxdb-$(VERSION).tar.gz
	cd influxdb-$(VERSION) && env PATH=$(GOROOT)/bin:$(PATH) go mod vendor
	tar czf influxdb-$(VERSION).tar.gz influxdb-$(VERSION)
	rm -rf influxdb-$(VERSION)
