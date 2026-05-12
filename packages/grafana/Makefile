include ../../Makefile.omd

NAME       = grafana
CHANGELOG  = https://github.com/grafana/grafana/blob/main/CHANGELOG.md
VERSION    = 12.4.3+security-02
SRC        = $(NAME)-$(VERSION).tar.xz
GOPATH     = go
GOPKG      = 1.26
GOVERSION  = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
PWD        = $(shell pwd)
GO         = export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION) && export GOPATH=$(PWD)/$(GOPATH)/ && export PATH=$(PWD)/build_bin:$$GOROOT/bin:$$PATH && export GOFLAGS=-buildvcs=false && go
ifeq ($(shell uname -m),x86_64)
MACHINE=amd64
else ifeq ($(shell uname -m),aarch64)
MACHINE=arm64
else
$(error arch $(shell uname -m ) not supported)
endif

# there is usually more space here, and /tmp is a tmpfs on most machines nowadays
export TMPDIR=/var/tmp

.PHONY: skel

build:
	tar xfJ $(SRC)
	cd $(GOPATH)/src/github.com/grafana/grafana && tar xfJ $(PWD)/public.tar.xz
	cd $(GOPATH)/src/github.com/grafana/grafana && $(GO) run build.go build
	mkdir -p ./dest/
	install -m 755 $(GOPATH)/src/github.com/grafana/grafana/bin/linux-$(MACHINE)/grafana     ./dest/grafana
	install -m 755 $(GOPATH)/src/github.com/grafana/grafana/bin/linux-$(MACHINE)/grafana-cli ./dest/grafana-cli
	chmod -R 777 $(GOPATH)
	rm -rf $(GOPATH)
	strip ./dest/grafana
	$(UPX) ./dest/grafana
	rm -rf /var/tmp/go-build*

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 ./dest/grafana     $(DESTDIR)$(OMD_ROOT)/bin/grafana
	install -m 755 ./dest/grafana-cli $(DESTDIR)$(OMD_ROOT)/bin/grafana-cli
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/grafana
	tar xfJ public.tar.xz -C $(DESTDIR)$(OMD_ROOT)/share/grafana
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/grafana/conf
	install -m 644 defaults.ini $(DESTDIR)$(OMD_ROOT)/share/grafana/conf/
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/grafana/tools/
	cp -rp 01-grafana.yml $(DESTDIR)$(OMD_ROOT)/share/grafana/
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/python
	mkdir -p $(DESTDIR)$(OMD_ROOT)/var/tmp
	install -m 755 grafanactl $(DESTDIR)$(OMD_ROOT)/bin/
	# Take care of path and format of plugin zip/tgz files
	# Download from https://grafana.com/grafana/plugins
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/grafana/plugins-available
	unzip grafana-clock-panel-3.2.2.zip -d $(DESTDIR)$(OMD_ROOT)/share/grafana/plugins-available
	unzip heywesty-trafficlight-panel-1.0.0.zip -d $(DESTDIR)$(OMD_ROOT)/share/grafana/plugins-available

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
	rm -rf dest

upstream: public package

package:
	mkdir -p $(GOPATH)/src/github.com/grafana/
	cd $(GOPATH)/src/github.com/grafana && \
		git clone --depth=1 --branch="v$(VERSION)" https://github.com/grafana/grafana.git
	echo "run make gen-go"
	cd $(GOPATH)/src/github.com/grafana/grafana && \
		export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION); \
		export GOPATH=$(PWD)/$(GOPATH)/; \
		export PATH=$$GOROOT/bin:$$PATH; \
		make gen-go
	# clean up to reduce dependencies
	find $(GOPATH)/src/github.com/grafana/grafana -type f | grep _test.go | xargs -r rm -f
	rm $(GOPATH)/src/github.com/grafana/grafana/pkg/build/cmd/e2e*
	cd $(GOPATH)/src/github.com/grafana/grafana && \
		$(GO) mod tidy
	echo "build app"
	cd $(GOPATH)/src/github.com/grafana/grafana && \
		$(GO) run build.go setup
	rm -rf $(GOPATH)/src/github.com/grafana/grafana/scripts/go/bin
	rm -f $(GOPATH)/src/github.com/grafana/grafana/yarn.lock
	rm -rf $(GOPATH)/src/github.com/grafana/grafana/.yarn
	rm -rf $(GOPATH)/src/github.com/grafana/grafana/docs
	rm -rf $(GOPATH)/src/github.com/grafana/grafana/public
	find $(GOPATH) -type d -name dockerenv | xargs -r rm -rf
	echo "packaging"
	rm -f grafana-*.tar.xz
	XZ_OPT=-8 tar cfJ $(SRC) --exclude=.git $(GOPATH)/src/
	$(MAKE) clean

public:
	test -f grafana-$(VERSION).linux-amd64.tar.gz || wget https://dl.grafana.com/oss/release/grafana-$(VERSION).linux-amd64.tar.gz
	tar zxf grafana-$(VERSION).linux-amd64.tar.gz
	# clean up
	rm -rf grafana-*/public/test
	rm -rf grafana-*/public/sass
	find grafana-*/public/ -type f | grep '.ts$$' | xargs -r rm -f
	find grafana-*/public/ -type f | grep '.map$$' | xargs -r rm -f
	find grafana-*/public/ -type d -name demo | xargs -r rm -rf
	cd grafana-*/. && XZ_OPT=-8 tar cfJ ../public.tar.xz public
	rm grafana-$(VERSION).linux-amd64.tar.gz
	rm -rf grafana-*/
	wget "https://raw.githubusercontent.com/grafana/grafana/v$(VERSION)/conf/defaults.ini" -O defaults.ini
# DO NOT TOUCH defaults.ini, update grafana.ini in skel instead
