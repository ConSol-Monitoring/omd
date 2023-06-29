include ../../../Makefile.omd

NAME        = check_prometheus
VERSION     = main
DIR         = $(NAME)-$(VERSION)
SRC         = $(DIR).tar.gz
GOPKG       = 1.20
GOVERSION   = $(shell grep ^VERSION ../../go-${GOPKG}/Makefile | awk '{ print $$3 }')
GITURL      = github.com/consol-monitoring/$(NAME)
# GIT TAG is set automatically by "make upstream" or "make package"
GIT_TAG     = 501fd81

build:
	tar zxf $(SRC)
	cd $(DIR) && tar zxf ../dependencies.tar.gz
	export PATH=$(shell pwd)/../../go-$(GOPKG)/go-$(GOVERSION)/bin:$$PATH && \
		cd $(DIR) && go build -ldflags "-s -w -X main.Build=$(OMD_VERSION)-$(GIT_TAG)"
	mv $(DIR)/check_prometheus .
	rm -rf $(DIR)

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins
	install -m 755 check_prometheus $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins

skel:

clean:
	rm -rf $(DIR)
	rm -f check_prometheus

package: clean
	git clone --depth=1 --branch "$(VERSION)" https://$(GITURL) $(DIR)
	tar zcf $(SRC) --exclude=.git --exclude=*_test.go $(DIR)
	cd $(DIR) && sed -i ../Makefile -e 's/^GIT_TAG.*$$/GIT_TAG     = '$$(git describe --always --tags)'/g'
	rm -rf $(DIR)

deps: clean
	git clone --depth=1 --branch "$(VERSION)" https://$(GITURL) $(DIR)
	export PATH=$(shell pwd)/../../go-$(GOPKG)/go-$(GOVERSION)/bin:$$PATH && \
		cd $(DIR) && go mod vendor
	cd $(DIR) && tar zcf ../dependencies.tar.gz vendor
	rm -rf $(DIR)

upstream: clean
	$(MAKE) deps
	$(MAKE) package
