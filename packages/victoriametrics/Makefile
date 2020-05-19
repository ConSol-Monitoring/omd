include ../../Makefile.omd

NAME       = victoriametrics
PWD        = $(shell pwd)

#for binary downloads
VERSION    = v1.34.7
# url defined in get_victoriametrics

# for vmctl build
# GIT_TAG: TODO: still set manually for new master version in git repo main.go! no release/version Branches
GIT_TAG     = 0.0.2
SRC         = vmctl-$(GIT_TAG).tar.gz
GOPKG       = 1.14
GOVERSION   = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
GOPATH      = go
GITBASE     = github.com/VictoriaMetrics
GITURL      = $(GITBASE)/vmctl


.PHONY: skel

build:
	tar zxf $(SRC)
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
	cd $(GOPATH)/src/$(GITURL) && \
	make build

	echo "nothing to build for victoriametric, just install binary tars from git"

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	bash get_victoriametrics $(VERSION) extract . $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 *cron* $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(PWD)/$(GOPATH)/src/$(GITURL)/bin/vmctl $(DESTDIR)$(OMD_ROOT)/bin

skel:

clean:
	rm -rf $(GOPATH)

package: clean
	bash get_victoriametrics $(VERSION) download .
	# clone vmctl:
	mkdir -p $(GOPATH)
	export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION)/ && export GOPATH=$(PWD)/$(GOPATH)/ && PATH=$$GOROOT/bin:$$PATH && \
	mkdir -p $(GOPATH)/src/$(GITBASE) && \
	cd $(GOPATH)/src/$(GITBASE) && \
	git clone --depth=1 --branch "master" https://$(GITURL) && \
	cd $(PWD) && \
	tar zcf $(SRC) --exclude=.git --exclude=*_test.go $(GOPATH)/src/$(GITURL)

