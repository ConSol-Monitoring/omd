include ../../Makefile.omd

NAME       = grafana
VERSION    = 9.2.4
SRC        = $(NAME)-$(VERSION).tar.gz
GOPATH     = go
GOPKG      = 1.19
GOVERSION  = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
PWD        = $(shell pwd)
GO         = export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION) && export GOPATH=$(PWD)/$(GOPATH)/ && export PATH=$(PWD)/build_bin:$$GOROOT/bin:$$PATH && export GOFLAGS=-buildvcs=false && go

.PHONY: skel

build:
	tar zxf $(SRC)
	cd $(GOPATH)/src/github.com/grafana/grafana && $(GO) run build.go build

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(GOPATH)/src/github.com/grafana/grafana/bin/linux-amd64/grafana-server  $(DESTDIR)$(OMD_ROOT)/bin/grafana
	install -m 755 $(GOPATH)/src/github.com/grafana/grafana/bin/linux-amd64/grafana-cli  $(DESTDIR)$(OMD_ROOT)/bin/grafana-cli
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/grafana
	tar zxf public.tar.gz -C $(DESTDIR)$(OMD_ROOT)/share/grafana
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/grafana/conf
	install -m 644 defaults.ini $(DESTDIR)$(OMD_ROOT)/share/grafana/conf/
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/grafana/tools/
	cp -rp 01-grafana.yml $(DESTDIR)$(OMD_ROOT)/share/grafana/
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/python
	mkdir -p $(DESTDIR)$(OMD_ROOT)/var/tmp
	install -m 755 grafanactl $(DESTDIR)$(OMD_ROOT)/bin/
	# clean up
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/grafana/public/test
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/grafana/public/sass
	rm -rf $(DESTDIR)$(OMD_ROOT)/share/grafana/public/build/*.map
	# Take care of path and format of plugin zip/tgz files
	# Download from https://grafana.com/grafana/plugins
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/grafana/plugins-available
	tar zxf clock-panel-plugin-2.1.0.tar.gz -C $(DESTDIR)$(OMD_ROOT)/share/grafana/plugins-available
	tar zxf piechart-panel-plugin-1.6.2.tar.gz -C $(DESTDIR)$(OMD_ROOT)/share/grafana/plugins-available
	tar zxf snuids-trafficlights-panel-1.5.1.tar.gz -C $(DESTDIR)$(OMD_ROOT)/share/grafana/plugins-available

skel:
	sed -i -e 's|###APACHE_MODULE_DIR###|$(APACHE_MODULE_DIR)|g' \
	       $(SKEL)/etc/apache/conf.d/grafana.conf
	mkdir -p $(SKEL)/var/grafana/plugins
	for PLUGIN in $$(cd $(DESTDIR)$(OMD_ROOT)/share/grafana/plugins-available && ls -1); do \
		ln -sfn ../../../share/grafana/plugins-available/$$PLUGIN $(SKEL)/var/grafana/plugins/$$PLUGIN; \
	done

clean:
	[ ! -e $(GOPATH) ] || chmod -R 777 $(GOPATH)
	rm -rf $(GOPATH)

package: public clean
	$(GO) env
	mkdir -p $(GOPATH)/src/github.com/grafana/
	cd $(GOPATH)/src/github.com/grafana && \
		git clone --depth=1 --branch="v$(VERSION)" https://github.com/grafana/grafana.git
	cd $(GOPATH)/src/github.com/grafana/grafana && \
		$(GO) fmt ./...
	echo "Get everything"
	cd $(GOPATH)/src/github.com/grafana/grafana && \
		$(GO) mod vendor
	echo "run make gen-go"
	cd $(GOPATH)/src/github.com/grafana/grafana && \
		export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION); \
		export GOPATH=$(PWD)/$(GOPATH)/; \
		export PATH=$$GOROOT/bin:$$PATH; \
		make gen-go
	echo "build app"
	cd $(GOPATH)/src/github.com/grafana/grafana && \
		$(GO) run build.go setup
	echo "packageing"
	rm -f grafana-*.tar.gz
	tar zcf $(SRC) --exclude=.git $(GOPATH)/src/

public:
	wget https://dl.grafana.com/oss/release/grafana-$(VERSION).linux-amd64.tar.gz
	tar zxf grafana-$(VERSION).linux-amd64.tar.gz
	cd grafana-*/. && tar cfz ../public.tar.gz public
	rm grafana-$(VERSION).linux-amd64.tar.gz
	rm -rf grafana-*/
	wget "https://raw.githubusercontent.com/grafana/grafana/v$(VERSION)/conf/defaults.ini" -O defaults.ini
# DO NOT TOUCH defaults.ini, update grafana.ini in skel instead
