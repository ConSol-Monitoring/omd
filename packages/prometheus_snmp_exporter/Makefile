include ../../Makefile.omd

NAME       = prometheus_snmp_expoter
VERSION    = 0.3.0
BRANCH     = master
SRC        = $(NAME)-$(VERSION).tar.gz
GOPATH     = go
GOPKG      = 1.8
GOVERSION  = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
PWD        = $(shell pwd)
DATE       = $(shell date -u '+%Y-%m-%d_%I:%M:%S%p')
LDFLAGS    = "\
-X github.com/prometheus/snmp_exporter/vendor/github.com/prometheus/common/version.Version=$(VERSION) \
-X github.com/prometheus/snmp_exporter/vendor/github.com/prometheus/common/version.Revision=OMD-Labs-Patched \
-X github.com/prometheus/snmp_exporter/vendor/github.com/prometheus/common/version.Branch=$(BRANCH) \
-X github.com/prometheus/snmp_exporter/vendor/github.com/prometheus/common/version.BuildUser=OMD-Labs \
-X github.com/prometheus/snmp_exporter/vendor/github.com/prometheus/common/version.BuildDate=$(DATE) \
"

build:
	tar zxf $(SRC)
	set -e ; for p in patches/*.patch ; do \
	    echo "applying $$p..." ; \
	    ( cd $(PWD)/$(GOPATH) ; patch -p1 ) < $$p ; \
	done
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION) && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		cd $(PWD)/$(GOPATH)/src/github.com/prometheus/snmp_exporter && \
		go install -ldflags $(LDFLAGS)

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(PWD)/$(GOPATH)/bin/snmp_exporter  $(DESTDIR)$(OMD_ROOT)/bin

skel:

clean:
	rm -rf $(GOPATH)

package: clean
	mkdir -p $(GOPATH)
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION) && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		mkdir -p $(GOPATH)/src/github.com/prometheus/snmp_exporter && \
		cd $(GOPATH)/src/github.com/prometheus/ && \
		git clone --depth=1 --branch "v$(VERSION)" https://github.com/prometheus/snmp_exporter.git && \
		cd snmp_exporter && \
		cd .. && \
		go get -d ./... && \
		cd $(PWD) && \
		tar zcf $(SRC) $(GOPATH)/src/ --exclude=.git

