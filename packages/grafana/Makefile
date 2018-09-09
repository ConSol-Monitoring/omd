include ../../Makefile.omd

NAME       = grafana
VERSION    = 5.2.4
SRC        = $(NAME)-$(VERSION).tar.gz
GOPATH     = go
GOPKG      = 1.10
GOVERSION  = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
PWD        = $(shell pwd)
GO         = export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION) && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && go

.PHONY: skel

build:
	tar zxf $(SRC)
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION) && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		cd $(GOPATH)/src/github.com/grafana/grafana && \
		PATH=$(PWD)/build_bin:$$PATH go run build.go build

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(GOPATH)/src/github.com/grafana/grafana/bin/linux-amd64/grafana-server  $(DESTDIR)$(OMD_ROOT)/bin/grafana
	install -m 755 $(GOPATH)/src/github.com/grafana/grafana/bin/linux-amd64/grafana-cli  $(DESTDIR)$(OMD_ROOT)/bin/grafana-cli
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/grafana
	tar zxf public.tar.gz -C $(DESTDIR)$(OMD_ROOT)/share/grafana
	# change default fill option for influxdb to something useful
	sed -e 's/fill(null)/fill(none)/' -i $(DESTDIR)$(OMD_ROOT)/share/grafana/public/build/*.js -i $(DESTDIR)$(OMD_ROOT)/share/grafana/public/build/*.map
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/grafana/conf
	install -m 644 defaults.ini $(DESTDIR)$(OMD_ROOT)/share/grafana/conf/
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/grafana/tools/
	cp -rp go/src/github.com/grafana/grafana/tools/phantomjs $(DESTDIR)$(OMD_ROOT)/share/grafana/tools/
	cp -rp 01-grafana.yml $(DESTDIR)$(OMD_ROOT)/share/grafana/
	# This link is needed due to grafana does not ship with the binary
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/grafana/tools/phantomjs
	ln -s ../../../../bin/phantomjs $(DESTDIR)$(OMD_ROOT)/share/grafana/tools/phantomjs/phantomjs
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/python
	install -m 755 grafana_utils.py $(DESTDIR)$(OMD_ROOT)/lib/python/grafana_utils.py
	mkdir -p $(DESTDIR)$(OMD_ROOT)/var/tmp
	install -m 755 grafanactl $(DESTDIR)$(OMD_ROOT)/bin/

skel:
	sed -i -e 's|###APACHE_MODULE_DIR###|$(MODULE_DIR)|g' \
	       $(SKEL)/etc/apache/conf.d/grafana.conf
	mkdir -p $(SKEL)/var/grafana/plugins
	tar zxf clock-panel-plugin-0.1.0.tar.gz -C $(SKEL)/var/grafana/plugins
	tar zxf piechart-panel-plugin-1.3.3.tar.gz -C $(SKEL)/var/grafana/plugins

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
	wget --no-check-certificate https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-$(VERSION).linux-amd64.tar.gz
	tar zxf grafana-$(VERSION).linux-amd64.tar.gz
	cd grafana-*/. && tar cfz ../public.tar.gz public
	rm grafana-$(VERSION).linux-amd64.tar.gz
	rm -rf grafana-*/
	wget "https://raw.githubusercontent.com/grafana/grafana/v$(VERSION)/conf/defaults.ini" -O defaults.ini
	sed -i -e 's/^default_theme.*$$/default_theme = light/' defaults.ini

plugins:
	git clone --depth=1 https://github.com/grafana/piechart-panel.git
	tar zcf plugins.tar.gz piechart-panel --exclude=.git
	rm -rf piechart-panel
