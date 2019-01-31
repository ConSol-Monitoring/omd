include ../../Makefile.omd

.PHONY: skel

NAME       = prometheus
VERSION    = 2.7.1
BRANCH     = master
SRC        = $(NAME)-$(VERSION).tar.gz
GOPKG      = 1.11
GOVERSION  = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
PWD        = $(shell pwd)
GOFOLDER   = go
GOPATH     = $(PWD)/$(GOFOLDER)/
GOROOT     = $(PWD)/../go-$(GOPKG)/go-$(GOVERSION)
DATE       = $(shell date -u '+%Y-%m-%d_%H:%M:%S%p')
LDFLAGS    = "\
-X github.com/prometheus/$(NAME)/vendor/github.com/prometheus/common/version.Version=$(VERSION) \
-X github.com/prometheus/$(NAME)/vendor/github.com/prometheus/common/version.Revision=OMD-Labs \
-X github.com/prometheus/$(NAME)/vendor/github.com/prometheus/common/version.Branch=$(BRANCH) \
-X github.com/prometheus/$(NAME)/vendor/github.com/prometheus/common/version.BuildUser=OMD-Labs \
-X github.com/prometheus/$(NAME)/vendor/github.com/prometheus/common/version.BuildDate=$(DATE) \
-s -w \
"

build:
	tar zxf $(SRC)
	export GOROOT=$(GOROOT) && export GOPATH=$(GOPATH) && PATH=$$GOROOT/bin:$$PATH && \
		go install -ldflags $(LDFLAGS) github.com/prometheus/$(NAME)/cmd/prometheus && \
		go install -ldflags $(LDFLAGS) github.com/prometheus/$(NAME)/cmd/promtool

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(GOPATH)/bin/prometheus $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(GOPATH)/bin/promtool $(DESTDIR)$(OMD_ROOT)/bin

skel:
	mkdir -p $(SKEL)/etc/prometheus
	mkdir -p $(SKEL)/etc/prometheus/conf.d/custom
	echo "Use this dir for your hand-crafted configs." > $(SKEL)/etc/prometheus/conf.d/custom/README
	mkdir -p $(SKEL)/etc/prometheus/conf.d/dynamic
	echo "Use this dir for your automatically created configs. Use coshsh" > $(SKEL)/etc/prometheus/conf.d/dynamic/README
	cp -rp $(GOPATH)/src/github.com/prometheus/prometheus/consoles $(SKEL)/etc/prometheus
	cp -rp $(GOPATH)/src/github.com/prometheus/prometheus/console_libraries $(SKEL)/etc/prometheus
	mv $(SKEL)/etc/prometheus/consoles/index.html.example $(SKEL)/etc/prometheus/consoles/index.html
	sed -ri 's/index.html.example/index.html/g' $(SKEL)/etc/prometheus/console_libraries/menu.lib

	for p in patches/*.skel_patch ; do \
		echo "applying $$p..." ; \
		( cd $(SKEL) ; patch -p1 ) < $$p || exit 1; \
	done	

clean:
	rm -rf $(GOPATH)

package: clean
	export GOROOT=$(GOROOT) && export GOPATH=$(GOPATH) && PATH=$$GOROOT/bin:$$PATH && \
		mkdir -p $(GOPATH)/src/github.com/prometheus/ && \
		cd $(GOPATH)/src/github.com/prometheus/ && \
		git clone --depth=1 --branch "v$(VERSION)" https://github.com/prometheus/$(NAME).git && \
		cd $(NAME)/cmd/prometheus/ && go get -d && cd ../promtool && go get -d && \
		cd $(PWD) && \
		tar zcf $(SRC) $(GOFOLDER)/src/ --exclude=.git

