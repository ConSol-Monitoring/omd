include ../../Makefile.omd

NAME       = influxdb
VERSION    = 1.0.2
BRANCH     = 1.0
SRC        = $(NAME)-$(VERSION).tar.gz
GOPATH     = go
GOPKG      = 1.7
GOVERSION  = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
PWD        = $(shell pwd)
DATE       = $(shell date -u '+%Y-%m-%d_%I:%M:%S%p')

build:
	tar zxf $(SRC)
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION) && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		cd $(GOPATH)/src/github.com/influxdata && \
		go build ./... && \
		go install -ldflags "-X main.version=$(VERSION) -X main.buildTime=$(DATE)" ./...

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(PWD)/$(GOPATH)/bin/influx  $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(PWD)/$(GOPATH)/bin/influxd $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(PWD)/$(GOPATH)/bin/influx_tsm  $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(PWD)/$(GOPATH)/bin/influx_stress  $(DESTDIR)$(OMD_ROOT)/bin
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
		mkdir -p $(GOPATH)/src/github.com/influxdata/ && \
		cd $(GOPATH)/src/github.com/influxdata && \
		git clone --depth=1 --branch "$(BRANCH)" https://github.com/influxdata/influxdb.git && \
		cd influxdb && \
		git branch master && \
		git checkout master && \
		go get github.com/sparrc/gdm && \
		$(PWD)/$(GOPATH)/bin/gdm restore && \
		go fmt ./... && \
		cd .. && \
		go get ./... && \
		cd $(PWD) && \
		tar zcf $(SRC) $(GOPATH)/src/ --exclude=.git

