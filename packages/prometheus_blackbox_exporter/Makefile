include ../../Makefile.omd

.PHONY: skel

NAME       = blackbox_exporter
VERSION    = 0.15.0
BRANCH     = master
SRC        = $(NAME)-$(VERSION).tar.gz
GOPKG      = 1.12
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
		go install -ldflags $(LDFLAGS) github.com/prometheus/$(NAME)

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(GOPATH)/bin/$(NAME) $(DESTDIR)$(OMD_ROOT)/bin

skel:
	mkdir -p $(SKEL)/etc/blackbox_exporter
	cp $(GOPATH)/src/github.com/prometheus/blackbox_exporter/blackbox.yml $(SKEL)/etc/blackbox_exporter

clean:
	rm -rf $(GOPATH)

package: clean
	export GOROOT=$(GOROOT) && export GOPATH=$(GOPATH) && PATH=$$GOROOT/bin:$$PATH && \
		mkdir -p $(GOPATH)/src/github.com/prometheus/ && \
		cd $(GOPATH)/src/github.com/prometheus/ && \
		git clone --depth=1 --branch "v$(VERSION)" https://github.com/prometheus/$(NAME).git && \
		cd $(NAME) && go get -d && \
		cd $(PWD) && \
		tar zcf $(SRC) $(GOFOLDER)/src/ --exclude=.git

