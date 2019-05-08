include ../../../Makefile.omd

NAME        = check_influxdb
VERSION     = a44cf5ebbf4f71a9462571118ce53637a5bc9ab9
SRC         = $(NAME)-$(VERSION).tar.gz
GOPKG       = 1.12
GOVERSION   = $(shell grep ^VERSION ../../go-${GOPKG}/Makefile | awk '{ print $$3 }')
GOPATH      = go
PWD         = $(shell pwd)

build:
	tar zxf $(SRC)
	for p in patches/*.patch ; do \
	    echo "applying $$p..." ; \
	    ( cd $(PWD)/$(GOPATH)/src/github.com/griesbacher/check_influxdb; patch -p1 ) < $$p || exit 1; \
	done
	export GOROOT=$(PWD)/../../go-$(GOPKG)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
	go install -ldflags "-s -w" github.com/griesbacher/check_influxdb

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins
	install -m 755 $(PWD)/$(GOPATH)/bin/check_influxdb $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins

skel:

clean:
	rm -rf $(GOPATH)

package: clean
	mkdir -p $(GOPATH)
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		mkdir -p $(GOPATH)/src/github.com/griesbacher/check_influxdb && \
		cd $(GOPATH)/src/github.com/griesbacher/check_influxdb && \
		git clone https://github.com/griesbacher/check_influxdb . && \
		git checkout $(VERSION) && \
		cd $(PWD) && \
		tar zcf $(SRC) $(GOPATH)/src/ --exclude=.git --exclude=*_test.go

