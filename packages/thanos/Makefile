include ../../Makefile.omd


NAME       = thanos
VERSION    = 0.2.0
SRC        = $(NAME)-$(VERSION).tar.gz
GOPATH     = go
GOPKG      = 1.11
GOVERSION  = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
PWD        = $(shell pwd)
DATE       = $(shell date -u '+%Y-%m-%d_%I:%M:%S%p')

build:
	tar zxf $(SRC)
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION) && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		cd $(GOPATH)/src/github.com/improbable-eng/thanos && \
		make

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(PWD)/$(GOPATH)/src/github.com/improbable-eng/thanos/thanos  $(DESTDIR)$(OMD_ROOT)/bin

skel:

clean:
	rm -rf $(GOPATH)

package: clean
	mkdir -p $(GOPATH)
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION) && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
		go get -d github.com/improbable-eng/thanos/... && \
		cd $(GOPATH)/src/github.com/improbable-eng/thanos && \
		git checkout tags/v$(VERSION) && \
		cd $(PWD) && \
		find $(GOPATH)/src/ -type d -name ".git*" -exec chmod -R u+w {} \; && \
		find $(GOPATH)/src/ -name ".git*" -exec rm -R {} \; ; \
		tar zcf $(SRC) $(GOPATH)/src/ --exclude=.git

