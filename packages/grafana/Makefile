include ../../Makefile.omd

NAME       = grafana
VERSION    = 2.0
SRC        = $(NAME)-$(VERSION).tar.gz
GOPATH     = go
PWD        = $(shell pwd)
GO_VERSION = $(shell grep "^VERSION " ../go/Makefile | awk '{ print $$3 }')
GO         = export GOROOT=$(PWD)/../go/go-$(GO_VERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && go


build:
	tar zxf $(SRC)
	export GOROOT=$(PWD)/../go/go-$(GO_VERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		cd $(GOPATH)/src/github.com/grafana && \
		go build ./... && \
		go install ./...

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(GOPATH)/bin/grafana  $(DESTDIR)$(OMD_ROOT)/bin
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/grafana
	cp -rp $(GOPATH)/src/github.com/grafana/grafana/public $(DESTDIR)$(OMD_ROOT)/share/grafana

skel:

clean:
	rm -rf $(GOPATH)

package:
	$(GO) env
	mkdir -p $(GOPATH)/src/github.com/grafana/
	cd $(GOPATH)/src/github.com/grafana && \
		git clone --depth=1 https://github.com/grafana/grafana.git
	cd $(GOPATH)/src/github.com/grafana/grafana && \
		$(GO) fmt ./...
	echo "Get everything"
	cd $(GOPATH)/src/github.com/grafana/grafana && \
		$(GO) get -u -f -v ./...
	echo "build app"
	cd $(GOPATH)/src/github.com/grafana/grafana && \
		$(GO) run build.go setup
	echo "packageing"
	tar zcf $(SRC) $(GOPATH)/src/ --exclude=.git
	rm -rf $(GOPATH)
	cd skel/etc/grafana/ && wget --no-check-certificate "https://github.com/grafana/grafana/raw/master/conf/defaults.ini" -O defaults.ini

