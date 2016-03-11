include ../../Makefile.omd

NAME        = nagflux
VERSION     = 0.2.0
SRC         = $(NAME)-$(VERSION).tar.gz
GOVERSION   = 1.5
GOPATH      = go
PWD         = $(shell pwd)
CONFIG_FILE = $(DESTDIR)$(OMD_ROOT)/etc/nagflux/config.gcfg

build:
	tar zxf $(SRC)
	export GOROOT=$(PWD)/../go-$(GOVERSION)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
	go install github.com/griesbacher/nagflux

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(PWD)/$(GOPATH)/bin/nagflux  $(DESTDIR)$(OMD_ROOT)/bin
	mkdir -p $(DESTDIR)$(OMD_ROOT)/var/nagflux

skel:

clean:
	rm -rf $(GOPATH)

package: clean
	mkdir -p $(GOPATH)
	export GOROOT=$(PWD)/../go-$(GOVERSION)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		mkdir -p $(GOPATH)/src/github.com/griesbacher && \
		cd $(GOPATH)/src/github.com/griesbacher && \
		git clone --depth=1 --branch "v$(VERSION)" https://github.com/griesbacher/nagflux && \
		go get ./... && \
		cd $(PWD) && \
		tar zcf $(SRC) $(GOPATH)/src/ --exclude=.git

