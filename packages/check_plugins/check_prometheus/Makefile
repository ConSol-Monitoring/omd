include ../../../Makefile.omd

NAME        = check_prometheus
VERSION     = 0.0.1
SRC         = $(NAME)-$(VERSION).tar.gz
GOPKG       = 1.11
GOVERSION   = $(shell grep ^VERSION ../../go-${GOPKG}/Makefile | awk '{ print $$3 }')
GOPATH      = go
PWD         = $(shell pwd)

build:
	tar zxf $(SRC)
	export GOROOT=$(PWD)/../../go-$(GOPKG)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
	go install -ldflags "-s -w" github.com/griesbacher/check_prometheus

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins
	install -m 755 $(PWD)/$(GOPATH)/bin/check_prometheus $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins

skel:

clean:
	rm -rf $(GOPATH)

package: clean
	mkdir -p $(GOPATH)
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		mkdir -p $(GOPATH)/src/github.com/griesbacher && \
		cd $(GOPATH)/src/github.com/griesbacher && \
		git clone --depth=1 --branch "$(VERSION)" https://github.com/griesbacher/check_prometheus && \
		cd $(PWD) && \
		tar zcf $(SRC) $(GOPATH)/src/ --exclude=.git --exclude=*_test.go

