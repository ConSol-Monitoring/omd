include ../../Makefile.omd

NAME        = lmd
VERSION     = 1.0.2
SRC         = $(NAME)-$(VERSION).tar.gz
GOPKG       = 1.7
GOVERSION   = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
GOPATH      = go
PWD         = $(shell pwd)
#BRANCH      = v$(VERSION)
GITURL      = github.com/sni/lmd
BRANCH      = master

.PHONY: skel

build:
	tar zxf $(SRC)
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
	go install -ldflags "-X main.Build=$(OMD_VERSION)" $(GITURL)/lmd

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(PWD)/$(GOPATH)/bin/lmd  $(DESTDIR)$(OMD_ROOT)/bin

skel:

clean:
	rm -rf $(GOPATH)

package: clean
	mkdir -p $(GOPATH)
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		mkdir -p $(GOPATH)/src/github.com/sni && \
		cd $(GOPATH)/src/github.com/sni && \
		git clone --depth=1 --branch "$(BRANCH)" https://$(GITURL) && \
		go get ./... && \
		cd $(PWD) && \
		tar zcf $(SRC) $(GOPATH)/src/ --exclude=.git --exclude=*_test.go

