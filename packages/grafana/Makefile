include ../../Makefile.omd

NAME       = grafana
VERSION    = 2.6.0
SRC        = $(NAME)-$(VERSION).tar.gz
GOPATH     = go
GOVERSION  = 1.4
PWD        = $(shell pwd)
GO         = export GOROOT=$(PWD)/../go-$(GOVERSION)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && go

MODULE_DIR=$(APACHE_MODULE_DIR)
ifeq ($(shell uname -m),x86_64)
  MODULE_DIR=$(APACHE_MODULE_DIR_64)
endif

.PHONY: skel

build:
	tar zxf $(SRC)
	set -e ; for p in patches/*.patch ; do \
	    echo "applying $$p..." ; \
	    ( cd $(GOPATH) ; patch -p1 ) < $$p ; \
	done
	export GOROOT=$(PWD)/../go-$(GOVERSION)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		cd $(GOPATH)/src/github.com/grafana && \
		go build ./... && \
		go install ./...

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(GOPATH)/bin/grafana  $(DESTDIR)$(OMD_ROOT)/bin
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/grafana
	tar zxf public.tar.gz -C $(DESTDIR)$(OMD_ROOT)/share/grafana
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/grafana/conf
	install -m 644 defaults.ini $(DESTDIR)$(OMD_ROOT)/share/grafana/conf/
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/grafana/vendor/
	cp -rp go/src/github.com/grafana/grafana/vendor/phantomjs $(DESTDIR)$(OMD_ROOT)/share/grafana/vendor/

skel:
	sed -i -e 's|###APACHE_MODULE_DIR###|$(MODULE_DIR)|g' \
	       $(SKEL)/etc/apache/conf.d/grafana.conf

clean:
	rm -rf $(GOPATH)

package: public
	$(GO) env
	mkdir -p $(GOPATH)/src/github.com/grafana/
	cd $(GOPATH)/src/github.com/grafana && \
		git clone --depth=1 --branch="v$(VERSION)" https://github.com/grafana/grafana.git
	cd $(GOPATH)/src/github.com/grafana/grafana && \
		$(GO) fmt ./...
	echo "Get everything"
	-cd $(GOPATH)/src/github.com/grafana/grafana && \
		$(GO) get -u -f -v ./...
	echo "build app"
	cd $(GOPATH)/src/github.com/grafana/grafana && \
		$(GO) run build.go setup
	echo "packageing"
	tar zcf $(SRC) $(GOPATH)/src/ --exclude=.git
	rm -rf $(GOPATH)
	wget --no-check-certificate "https://github.com/grafana/grafana/raw/master/conf/defaults.ini" -O defaults.ini

public:
	wget --no-check-certificate https://grafanarel.s3.amazonaws.com/builds/grafana-$(VERSION).linux-x64.tar.gz
	tar zxf grafana-$(VERSION).linux-x64.tar.gz
	cd grafana-*/. && tar cfz ../public.tar.gz public
	rm grafana-$(VERSION).linux-x64.tar.gz
	rm -rf grafana-*/
