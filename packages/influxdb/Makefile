include ../../Makefile.omd

NAME       = influxdb
VERSION    = 1.7.1
SRC        = $(NAME)-$(VERSION).tar.gz
GOPATH     = go
GOPKG      = 1.11
GOVERSION  = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
PWD        = $(shell pwd)
DATE       = $(shell date -u '+%Y-%m-%d_%I:%M:%S%p')

build:
	tar zxf $(SRC)
	patch -p1 < influxdb_inspect_pattern.patch
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION) && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		cd $(GOPATH)/src/github.com/influxdata && \
		go build -ldflags "-s -w" ./... && \
		go install -ldflags "-X main.version=$(VERSION) -X main.buildTime=$(DATE) -s -w" ./...

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(PWD)/$(GOPATH)/bin/influx  $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(PWD)/$(GOPATH)/bin/influxd $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(PWD)/$(GOPATH)/bin/influx_inspect $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(PWD)/influxdb-dumper.py $(DESTDIR)$(OMD_ROOT)/bin
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins
	install -m 755 $(PWD)/check_influxdb.pl $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/histou/templates/default/
	install -m 644 $(PWD)/influxdb.simple $(DESTDIR)$(OMD_ROOT)/share/histou/templates/default/influxdb.simple

skel:

clean:
	rm -rf $(GOPATH)

package: clean
	mkdir -p $(GOPATH)
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION) && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		go get -d -u github.com/golang/dep && \
		go install github.com/golang/dep/cmd/dep && \
		mkdir -p $(GOPATH)/src/github.com/influxdata/ && \
		cd $(GOPATH)/src/github.com/influxdata && \
		git clone --depth=1 --branch "v$(VERSION)" https://github.com/influxdata/influxdb.git && \
		cd influxdb && \
		$(PWD)/$(GOPATH)/bin/dep ensure -vendor-only && \
		cd $(PWD) && \
		find $(GOPATH)/src/ -type d -name ".git*" -exec chmod -R u+w {} \; && \
		find $(GOPATH)/src/ -name ".git*" -exec rm -R {} \; ; \
		tar zcf $(SRC) $(GOPATH)/src/ --exclude=.git

