include ../../../Makefile.omd

NAME        = check_nsc_web
VERSION     = 0.5.3-consol
SRC         = $(NAME)-$(VERSION).tar.gz
GOPKG       = 1.19
GOVERSION   = $(shell grep ^VERSION ../../go-${GOPKG}/Makefile | awk '{ print $$3 }')
PWD         = $(shell pwd)
#BRANCH      = v$(VERSION)
#GITURL      = github.com/m-kraus
BRANCH      = fix_unsolicited_response
GITURL      = github.com/ConSol
GOFOLDER    = go
GOPATH      = $(PWD)/$(GOFOLDER)/
GOROOT      = $(PWD)/../../go-$(GOPKG)/go-$(GOVERSION)

.PHONY: skel

build:
	tar zxf $(SRC)
	export GO111MODULE=auto && \
	export GOROOT=$(GOROOT) && export GOPATH=$(GOPATH) && PATH=$$GOROOT/bin:$$PATH && \
		cd $(GOPATH)/src/${GITURL}/${NAME} && \
		CGO_ENABLED=0 go build -ldflags "-s -w" $(NAME).go

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins
	install -m 755 $(GOPATH)/src/${GITURL}/${NAME}/${NAME} $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins

skel:

clean:
	rm -f $(NAME)
	rm -f $(NAME).go
	rm -rf $(GOPATH)

package: clean
	mkdir -p $(GOPATH)
	export GOROOT=$(GOROOT) && export GOPATH=$(GOPATH) && PATH=$$GOROOT/bin:$$PATH && \
		mkdir -p $(GOPATH)/src/$(GITURL) && \
		cd $(GOPATH)/src/$(GITURL) && \
		git clone --depth=1 --branch "$(BRANCH)" https://$(GITURL)/$(NAME) && \
		cd $(NAME) && go get -d && \
		cd $(PWD) && \
		tar zcf $(SRC) --exclude=.git $(GOFOLDER)/src/

