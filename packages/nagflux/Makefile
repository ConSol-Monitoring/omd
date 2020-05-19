include ../../Makefile.omd

NAME        = nagflux
VERSION     = master
SRC         = $(NAME)-$(VERSION).tar.gz
GOPKG       = 1.14
GOVERSION   = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
GOPATH      = go
PWD         = $(shell pwd)
CONFIG_FILE = $(DESTDIR)$(OMD_ROOT)/etc/nagflux/config.gcfg
SRC_URL     = github.com/ConSol

build:
	tar zxf $(SRC)
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
	go install -ldflags "-s -w" $(SRC_URL)/$(NAME)

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(PWD)/$(GOPATH)/bin/nagflux  $(DESTDIR)$(OMD_ROOT)/bin
	mkdir -p $(DESTDIR)$(OMD_ROOT)/var/nagflux
	install -m 755 $(PWD)/migrate_pnp_to_nagflux $(DESTDIR)$(OMD_ROOT)/bin

skel:

clean:
	rm -rf $(GOPATH)

package: clean
	mkdir -p $(GOPATH)
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		mkdir -p $(GOPATH)/src/$(SRC_URL) && \
		cd $(GOPATH)/src/$(SRC_URL) && \
		git clone --depth=1 https://$(SRC_URL)/$(NAME) && \
		cd $(PWD) && \
		tar zcf $(SRC) --exclude=.git --exclude=*_test.go $(GOPATH)/src/

