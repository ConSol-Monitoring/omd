include ../../Makefile.omd

.PHONY: skel

NAME       = minio
VERSION    = RELEASE.2019-01-10T00-21-20Z
SRC        = $(NAME)-$(VERSION).tar.gz
GOPKG      = 1.12
GOVERSION  = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
PWD        = $(shell pwd)
GOPATH     = go
GOROOT     = $(PWD)/../go-$(GOPKG)/go-$(GOVERSION)
DATE       = $(shell date -u '+%Y-%m-%d_%H:%M:%S%p')
LDFLAGS    = "\
-X github.com/minio/$(NAME)/cmd.Version=$(VERSION) \
-s -w \
"

build:
	tar zxf $(SRC)
	export GOROOT=$(GOROOT) && export GOPATH=$(PWD)/$(GOPATH) && PATH=$$GOROOT/bin:$$PATH && \
		cd $(GOPATH)/src/github.com/minio/minio && \
		GOFLAGS="" CGO_ENABLED=0 go build -tags kqueue -ldflags $(LDFLAGS)

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(PWD)/$(GOPATH)/src/github.com/minio/minio/minio  $(DESTDIR)$(OMD_ROOT)/bin

skel:

clean:
	rm -rf $(GOPATH)

package: clean
	export GOROOT=$(GOROOT) && export GOPATH=$(PWD)/$(GOPATH) && PATH=$$GOROOT/bin:$$PATH && \
		go get -d github.com/minio/minio/... && \
		cd $(GOPATH)/src/github.com/minio/minio && \
		git checkout tags/$(VERSION) && \
		cd $(PWD) && \
		find $(GOPATH)/src/ -type d -name ".git*" -exec chmod -R u+w {} \; && \
		find $(GOPATH)/src/ -name ".git*" -exec rm -R {} \; ; \
		tar zcf $(SRC) --exclude=.git $(GOPATH)/src/
