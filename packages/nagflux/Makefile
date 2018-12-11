include ../../Makefile.omd

NAME        = nagflux
VERSION     = 0.4.1
SRC         = $(NAME)-$(VERSION).tar.gz
GOPKG       = 1.11
GOVERSION   = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
GOPATH      = go
PWD         = $(shell pwd)
CONFIG_FILE = $(DESTDIR)$(OMD_ROOT)/etc/nagflux/config.gcfg

build:
	tar zxf $(SRC)
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
	go install -ldflags "-s -w" github.com/griesbacher/nagflux

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
		mkdir -p $(GOPATH)/src/github.com/griesbacher && \
		cd $(GOPATH)/src/github.com/griesbacher && \
		git clone --depth=1 --branch "v$(VERSION)" https://github.com/griesbacher/nagflux && \
		cd $(PWD) && \
		tar zcf $(SRC) $(GOPATH)/src/ --exclude=.git --exclude=*_test.go

