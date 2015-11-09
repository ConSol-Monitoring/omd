include ../../Makefile.omd

NAME       = influxdb
VERSION    = 0.9.4.2
SRC        = $(NAME)-$(VERSION).tar.gz
GOPATH     = go
GOVERSION  = 1.5
PWD        = $(shell pwd)

build:
	tar zxf $(SRC)
	export GOROOT=$(PWD)/../go-$(GOVERSION)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
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

package: clean
	mkdir -p $(GOPATH)
	export GOROOT=$(PWD)/../go-$(GOVERSION)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		mkdir -p $(GOPATH)/src/github.com/influxdb/ && \
		cd $(GOPATH)/src/github.com/influxdb && \
		git clone --depth=1 --branch "v$(VERSION)" https://github.com/influxdb/influxdb.git && \
		cd influxdb && \
		git branch master && \
		git checkout master && \
		go fmt ./... && \
		cd .. && \
		go get ./... && \
		cd $(PWD) && \
		tar zcf $(SRC) $(GOPATH)/src/ --exclude=.git

