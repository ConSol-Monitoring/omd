include ../../Makefile.omd

NAME       = influxdb
VERSION    = 0.9
SRC        = $(NAME)-$(VERSION).tar.gz
GOPATH     = go
PWD        = $(shell pwd)
GO_VERSION = $(shell grep "^VERSION " ../go/Makefile | awk '{ print $$3 }')

build:
	tar zxf $(SRC)
	export GOROOT=$(PWD)/../go/go-$(GO_VERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		cd $(GOPATH)/src/github.com/influxdb && \
		go build ./... && \
		go install ./...

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(PWD)/$(GOPATH)/bin/influx  $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(PWD)/$(GOPATH)/bin/influxd $(DESTDIR)$(OMD_ROOT)/bin

skel:

clean:
	rm -rf $(GOPATH)

package:
	mkdir -p $(GOPATH)
	export GOROOT=$(PWD)/../go/go-$(GO_VERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		mkdir -p $(GOPATH)/src/github.com/influxdb/ && \
		cd $(GOPATH)/src/github.com/influxdb && \
		git clone https://github.com/influxdb/influxdb.git && \
		cd influxdb && \
		go fmt ./... && \
		cd .. && \
		go get -u -f ./... && \
		cd $(PWD) && \
		tar zcf $(SRC) $(GOPATH)/src/
	rm -rf $(GOPATH)

