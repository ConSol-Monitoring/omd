include ../../Makefile.omd

NAME       = grafana
VERSION    = 4.1.1
TIMESTAMP  = 1484211277
SRC        = $(NAME)-$(VERSION).tar.gz
GOPATH     = go
GOPKG      = 1.7
GOVERSION  = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
PWD        = $(shell pwd)
GO         = export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION) && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && go

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
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION) && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		cd $(GOPATH)/src/github.com/grafana/grafana && \
		PATH=$(PWD)/build_bin:$$PATH go run build.go build

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(GOPATH)/src/github.com/grafana/grafana/bin/grafana-server  $(DESTDIR)$(OMD_ROOT)/bin/grafana
	install -m 755 $(GOPATH)/src/github.com/grafana/grafana/bin/grafana-cli  $(DESTDIR)$(OMD_ROOT)/bin/grafana-cli
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/grafana
	tar zxf public.tar.gz -C $(DESTDIR)$(OMD_ROOT)/share/grafana
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/grafana/conf
	install -m 644 defaults.ini $(DESTDIR)$(OMD_ROOT)/share/grafana/conf/
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/grafana/vendor/
	cp -rp go/src/github.com/grafana/grafana/vendor/phantomjs $(DESTDIR)$(OMD_ROOT)/share/grafana/vendor/
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/python
	install -m 755 grafana_utils.py $(DESTDIR)$(OMD_ROOT)/lib/python/grafana_utils.py
	mkdir -p $(DESTDIR)$(OMD_ROOT)/var/tmp
	install -m 755 grafanactl $(DESTDIR)$(OMD_ROOT)/bin/

skel:
	sed -i -e 's|###APACHE_MODULE_DIR###|$(MODULE_DIR)|g' \
	       $(SKEL)/etc/apache/conf.d/grafana.conf
	mkdir -p $(SKEL)/var/grafana/plugins
	tar zxf histogram-panel-plugin-0.1.6.tar.gz -C $(SKEL)/var/grafana/plugins
	tar zxf clock-panel-plugin-0.0.8.tar.gz -C $(SKEL)/var/grafana/plugins
	tar zxf piechart-panel-plugin-1.1.4.tar.gz -C $(SKEL)/var/grafana/plugins

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
	cd $(GOPATH)/src/github.com/grafana/grafana && \
		$(GO) get github.com/go-macaron/binding
	echo "build app"
	cd $(GOPATH)/src/github.com/grafana/grafana && \
		$(GO) run build.go setup
	echo "packageing"
	tar zcf $(SRC) $(GOPATH)/src/ --exclude=.git

public:
	wget --no-check-certificate https://grafanarel.s3.amazonaws.com/builds/grafana-$(VERSION)-$(TIMESTAMP).linux-x64.tar.gz
	tar zxf grafana-$(VERSION)-$(TIMESTAMP).linux-x64.tar.gz
	cd grafana-*/. && tar cfz ../public.tar.gz public
	rm grafana-$(VERSION)-$(TIMESTAMP).linux-x64.tar.gz
	rm -rf grafana-*/
	wget --no-check-certificate "https://github.com/grafana/grafana/raw/master/conf/defaults.ini" -O defaults.ini

plugins:
	git clone --depth=1 https://github.com/grafana/piechart-panel.git
	tar zcf plugins.tar.gz piechart-panel --exclude=.git
	rm -rf piechart-panel
