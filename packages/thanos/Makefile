include ../../Makefile.omd


NAME       = thanos
VERSION    = 0.2.1
SRC        = $(NAME)-$(VERSION).tar.gz
GOPATH     = go
GOPKG      = 1.11
GOVERSION  = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
PWD        = $(shell pwd)
DATE       = $(shell date -u '+%Y-%m-%d_%I:%M:%S%p')
LDFLAGS    = "\
-X github.com/prometheus/$(NAME)/vendor/github.com/prometheus/common/version.Version=$(VERSION) \
-X github.com/prometheus/$(NAME)/vendor/github.com/prometheus/common/version.Revision=OMD-Labs \
-X github.com/prometheus/$(NAME)/vendor/github.com/prometheus/common/version.Branch=v$(VERSION) \
-X github.com/prometheus/$(NAME)/vendor/github.com/prometheus/common/version.BuildUser=OMD-Labs \
-X github.com/prometheus/$(NAME)/vendor/github.com/prometheus/common/version.BuildDate=$(DATE) \
-s -w \
"

build:
	tar zxf $(SRC)
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION) && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		go install -ldflags $(LDFLAGS) github.com/improbable-eng/$(NAME)/cmd/thanos

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(GOPATH)/bin/thanos $(DESTDIR)$(OMD_ROOT)/bin

skel:

clean:
	rm -rf $(GOPATH)

package: clean
	mkdir -p $(GOPATH)
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION) && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
        go get -d -u github.com/golang/dep && \
        go install github.com/golang/dep/cmd/dep && \
		go get -d github.com/improbable-eng/thanos/... && \
		cd $(GOPATH)/src/github.com/improbable-eng/thanos && \
		git checkout tags/v$(VERSION) && \
		$(PWD)/$(GOPATH)/bin/dep ensure -vendor-only && \
		cd $(PWD) && \
		find $(GOPATH)/src/ -type d -name ".git*" -exec chmod -R u+w {} \; && \
		find $(GOPATH)/src/ -name ".git*" -exec rm -R {} \; ; \
		tar zcf $(SRC) $(GOPATH)/src/ --exclude=.git

