include ../../Makefile.omd

NAME       = grafana
VERSION    = 2.0
SRC        = $(NAME)-$(VERSION).tar.gz
GOPATH     = go
PWD        = $(shell pwd)
GO_VERSION = $(shell grep "^VERSION " ../go/Makefile | awk '{ print $$3 }')
#GO         = export GOROOT=$(PWD)/../go/go-$(GO_VERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && export PATH=$(PWD)/../go/go-$(GO_VERSION)/bin:$$PATH && go
GO         = export GOROOT=$(PWD)/../go/go-$(GO_VERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH 


build:
	tar zxf $(SRC)
	export GOROOT=$(PWD)/../go/go-$(GO_VERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		cd $(GOPATH)/src/github.com/grafana && \
		go build ./... && \
		go install ./...

install:
#	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
#	install -m 755 $(PWD)/$(GOPATH)/bin/influx  $(DESTDIR)$(OMD_ROOT)/bin
#	install -m 755 $(PWD)/$(GOPATH)/bin/influxd $(DESTDIR)$(OMD_ROOT)/bin

skel:

clean:
	rm -rf $(GOPATH)

package:
	$(GO) go env
	mkdir -p $(GOPATH)/src/github.com/grafana/
	cd $(GOPATH)/src/github.com/grafana && \
		git clone --depth=1 https://github.com/grafana/grafana.git
	cd $(GOPATH)/src/github.com/grafana/grafana && \
		$(GO) fmt ./...
	echo "Get everything$(shell pwd)"
	cd $(GOPATH)/src/github.com/grafana/grafana && \
		bash -c "$(GO) get -u -f -v ./..."
	echo "build app"
	cd $(GOPATH)/src/github.com/grafana/grafana && \
		go run build.go setup
	echo "packageing"
	tar zcf $(SRC) $(GOPATH)/src/
	rm -rf $(GOPATH)

