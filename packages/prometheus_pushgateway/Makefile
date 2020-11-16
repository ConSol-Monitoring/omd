include ../../Makefile.omd

.PHONY: skel

NAME       = pushgateway
VERSION    = 1.2.0
BRANCH     = master
SRC        = $(NAME)-$(VERSION).tar.gz
GOPKG      = 1.15
GOVERSION  = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
PWD        = $(shell pwd)
GOFOLDER   = go
GOPATH     = /dev/null
GOROOT     = $(PWD)/../go-$(GOPKG)/go-$(GOVERSION)
DATE       = $(shell date -u '+%FT%TZ')
LDFLAGS    = "\
-X github.com/prometheus/common/version.Version=$(VERSION) \
-X github.com/prometheus/common/version.Revision=release-tar-ball \
-X github.com/prometheus/common/version.Branch=$(BRANCH) \
-X github.com/prometheus/common/version.BuildUser=OMD-Labs \
-X github.com/prometheus/common/version.BuildDate=$(DATE) \
-s -w \
"

build:
	tar zxf $(SRC)
	mkdir -p $(NAME)-$(VERSION)/build
	cd $(NAME)-$(VERSION) && \
	$(GOROOT)/bin/go build -mod=vendor -trimpath -ldflags $(LDFLAGS) -o build/$(NAME) github.com/prometheus/$(NAME)

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(NAME)-$(VERSION)/build/$(NAME) $(DESTDIR)$(OMD_ROOT)/bin

skel:

clean:
	rm -rf $(NAME)-$(VERSION)

package: clean
	curl -fLo $(NAME)-$(VERSION).tar.gz https://github.com/prometheus/$(NAME)/archive/v$(VERSION).tar.gz
