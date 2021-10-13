include ../../../Makefile.omd

NAME        = check_prometheus
VERSION     = master
SRC         = $(NAME)-$(VERSION).tar.gz
GOPKG       = 1.17
GOVERSION   = $(shell grep ^VERSION ../../go-${GOPKG}/Makefile | awk '{ print $$3 }')
GOPATH      = go
PWD         = $(shell pwd)
GITBASE     = github.com/consol
GITURL      = $(GITBASE)/$(NAME)
# GIT_TAG: TODO: still set manually for new master version in git repo!
GIT_TAG     = 0.0.2

build:
	tar zxf $(SRC)
	export GO111MODULE=auto && \
	export GOROOT=$(PWD)/../../go-$(GOPKG)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
	go install -ldflags "-s -w -X main.Build=$(OMD_VERSION)-$(GIT_TAG)" $(GITURL)

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins
	install -m 755 $(PWD)/$(GOPATH)/bin/check_prometheus $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins

skel:

clean:
	rm -rf $(GOPATH)

package: clean
	mkdir -p $(GOPATH)
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
                mkdir -p $(GOPATH)/src/$(GITBASE) && \
                cd $(GOPATH)/src/$(GITBASE) && \
                git clone --depth=1 --branch "$(VERSION)" https://$(GITURL) && \
                cd $(PWD) && \
                tar zcf $(SRC) --exclude=.git --exclude=*_test.go $(GOPATH)/src/$(GITURL)
