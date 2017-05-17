include ../../Makefile.omd

.PHONY: skel

NAME       = prometheus
VERSION    = 1.6.2
BRANCH     = master
SRC        = $(NAME)-$(VERSION).tar.gz
GOPATH     = go
GOPKG      = 1.8
GOVERSION  = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
PWD        = $(shell pwd)
DATE       = $(shell date -u '+%Y-%m-%d_%H:%M:%S%p')
LDFLAGS    = "\
-X github.com/prometheus/prometheus/vendor/github.com/prometheus/common/version.Version=$(VERSION) \
-X github.com/prometheus/prometheus/vendor/github.com/prometheus/common/version.Revision=OMD-Labs \
-X github.com/prometheus/prometheus/vendor/github.com/prometheus/common/version.Branch=$(BRANCH) \
-X github.com/prometheus/prometheus/vendor/github.com/prometheus/common/version.BuildUser=OMD-Labs \
-X github.com/prometheus/prometheus/vendor/github.com/prometheus/common/version.BuildDate=$(DATE) \
"

build:
	tar zxf $(SRC)
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION) && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		cd $(PWD)/$(GOPATH)/src/github.com/prometheus/prometheus && \
		go install -ldflags $(LDFLAGS) github.com/prometheus/prometheus/cmd/prometheus && \
		go install -ldflags $(LDFLAGS) github.com/prometheus/prometheus/cmd/promtool  

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(PWD)/$(GOPATH)/bin/prometheus $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(PWD)/$(GOPATH)/bin/promtool $(DESTDIR)$(OMD_ROOT)/bin

skel:
	mkdir -p $(SKEL)/etc/prometheus
	mkdir -p $(SKEL)/etc/prometheus/conf.d/custom
	echo "Use this dir for your hand-crafted configs." > $(SKEL)/etc/prometheus/conf.d/custom/README
	mkdir -p $(SKEL)/etc/prometheus/conf.d/dynamic
	echo "Use this dir for your automatically created configs. Use coshsh" > $(SKEL)/etc/prometheus/conf.d/dynamic/README
	cp -rp $(PWD)/$(GOPATH)/src/github.com/prometheus/prometheus/consoles $(SKEL)/etc/prometheus
	cp -rp $(PWD)/$(GOPATH)/src/github.com/prometheus/prometheus/console_libraries $(SKEL)/etc/prometheus
	mv $(SKEL)/etc/prometheus/consoles/index.html.example $(SKEL)/etc/prometheus/consoles/index.html
	sed -ri 's/index.html.example/index.html/g' $(SKEL)/etc/prometheus/console_libraries/menu.lib

clean:
	rm -rf $(GOPATH)

package: clean
	mkdir -p $(GOPATH)
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION) && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		mkdir -p $(GOPATH)/src/github.com/prometheus/prometheus && \
		cd $(GOPATH)/src/github.com/prometheus/ && \
		git clone --depth=1 --branch "v$(VERSION)" https://github.com/prometheus/prometheus.git && \
		cd prometheus/ && \
		cd cmd/prometheus/ && go get -d && cd ../../ && \
		cd cmd/promtool/ && go get -d && cd ../../ && \
		cd $(PWD) && \
		tar zcf $(SRC) $(GOPATH)/src/ --exclude=.git

