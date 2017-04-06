include ../../../Makefile.omd

NAME        = check_influxdb
VERSION     = 0.0.5
SRC         = $(NAME)-$(VERSION).tar.gz
GOPKG       = 1.8
GOVERSION   = $(shell grep ^VERSION ../../go-${GOPKG}/Makefile | awk '{ print $$3 }')
GOPATH      = go
PWD         = $(shell pwd)

build:
	tar zxf $(SRC)
	export GOROOT=$(PWD)/../../go-$(GOPKG)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
	go install github.com/griesbacher/check_influxdb

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins
	install -m 755 $(PWD)/$(GOPATH)/bin/check_influxdb $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins

skel:

clean:
	rm -rf $(GOPATH)

package: clean
	mkdir -p $(GOPATH)
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		mkdir -p $(GOPATH)/src/github.com/griesbacher && \
		cd $(GOPATH)/src/github.com/griesbacher && \
		git clone --depth=1 --branch "v$(VERSION)" https://github.com/griesbacher/check_influxdb && \
		cd $(PWD) && \
		tar zcf $(SRC) $(GOPATH)/src/ --exclude=.git --exclude=*_test.go

