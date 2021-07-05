include ../../Makefile.omd

.PHONY: skel

NAME       = alertmanager
VERSION    = 0.22.2
BRANCH     = master
SRC        = $(NAME)-$(VERSION).tar.gz
GOPKG      = 1.16
GOVERSION  = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
PWD        = $(shell pwd)
GOFOLDER   = go
GOPATH     = /dev/null
GOROOT     = $(PWD)/../go-$(GOPKG)/go-$(GOVERSION)
DATE       = $(shell TZ=UTC date -u '+%FT%TZ')
LDFLAGS    = "\
-X github.com/prometheus/common/version.Version=$(VERSION) \
-X github.com/prometheus/common/version.Revision=release-tar-ball \
-X github.com/prometheus/common/version.Branch=$(BRANCH) \
-X github.com/prometheus/common/version.BuildUser=OMD-Labs \
-X github.com/prometheus/common/version.BuildDate=$(DATE) \
-s -w \
"

build:
	tar zxf $(SRC)
	cd $(NAME)-$(VERSION) && \
	    $(GOROOT)/bin/go build -trimpath -ldflags $(LDFLAGS) -mod=vendor -o build/alertmanager github.com/prometheus/$(NAME)/cmd/alertmanager
	cd $(NAME)-$(VERSION) && \
	    $(GOROOT)/bin/go build -trimpath -ldflags $(LDFLAGS) -mod=vendor -o build/amtool github.com/prometheus/$(NAME)/cmd/amtool

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(NAME)-$(VERSION)/build/alertmanager $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(NAME)-$(VERSION)/build/amtool $(DESTDIR)$(OMD_ROOT)/bin

skel:
	mkdir -p $(SKEL)/etc/alertmanager
	mkdir -p $(SKEL)/etc/alertmanager/conf.d/custom
	echo "Use this folder for your hand-crafted configs." > $(SKEL)/etc/alertmanager/conf.d/custom/README
	mkdir -p $(SKEL)/etc/alertmanager/conf.d/dynamic
	echo "Use this folder for your automatically created configs. Use coshsh" > $(SKEL)/etc/alertmanager/conf.d/dynamic/README

	mkdir -p $(SKEL)/etc/alertmanager/alertmanager.d/routes/static
	echo "This folder contains files that come whith OMD" > $(SKEL)/etc/alertmanager/alertmanager.d/routes/static/README
	mkdir -p $(SKEL)/etc/alertmanager/alertmanager.d/routes/dynamic
	echo "Use this folder for your automatically created configs. Use coshsh" > $(SKEL)/etc/alertmanager/alertmanager.d/routes/dynamic/README
	mkdir -p $(SKEL)/etc/alertmanager/alertmanager.d/routes/custom
	echo "Use this folder for your hand-crafted configs." > $(SKEL)/etc/alertmanager/alertmanager.d/routes/custom/README

	mkdir -p $(SKEL)/etc/alertmanager/alertmanager.d/receivers/static
	echo "This folder contains files that come whith OMD" > $(SKEL)/etc/alertmanager/alertmanager.d/receivers/static/README
	mkdir -p $(SKEL)/etc/alertmanager/alertmanager.d/receivers/dynamic
	echo "Use this folder for your automatically created configs. Use coshsh" > $(SKEL)/etc/alertmanager/alertmanager.d/receivers/dynamic/README
	mkdir -p $(SKEL)/etc/alertmanager/alertmanager.d/receivers/custom
	echo "Use this folder for your hand-crafted configs." > $(SKEL)/etc/alertmanager/alertmanager.d/receivers/custom/README

	mkdir -p $(SKEL)/etc/alertmanager/alertmanager.d/inhibit_rules/static
	echo "This folder contains files that come whith OMD" > $(SKEL)/etc/alertmanager/alertmanager.d/inhibit_rules/static/README
	mkdir -p $(SKEL)/etc/alertmanager/alertmanager.d/inhibit_rules/dynamic
	echo "Use this folder for your automatically created configs. Use coshsh" > $(SKEL)/etc/alertmanager/alertmanager.d/inhibit_rules/dynamic/README
	mkdir -p $(SKEL)/etc/alertmanager/alertmanager.d/inhibit_rules/custom
	echo "Use this folder for your hand-crafted configs." > $(SKEL)/etc/alertmanager/alertmanager.d/inhibit_rules/custom/README

clean:
	rm -rf $(NAME)-$(VERSION)

package: clean
	curl -fLo $(NAME)-$(VERSION).tar.gz https://github.com/prometheus/$(NAME)/archive/v$(VERSION).tar.gz
	tar xf $(NAME)-$(VERSION).tar.gz
	cd $(NAME)-$(VERSION) && env PATH=$(GOROOT)/bin:$(PATH) go mod vendor
	tar czf $(NAME)-$(VERSION).tar.gz $(NAME)-$(VERSION)
	rm -r $(NAME)-$(VERSION)
