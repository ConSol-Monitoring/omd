include ../../Makefile.omd

.PHONY: skel

NAME       = alertmanager
VERSION    = 0.18.0
BRANCH     = master
SRC        = $(NAME)-$(VERSION).tar.gz
GOPKG      = 1.12
GOVERSION  = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
PWD        = $(shell pwd)
GOFOLDER   = go
GOPATH     = $(PWD)/$(GOFOLDER)/
GOROOT     = $(PWD)/../go-$(GOPKG)/go-$(GOVERSION)
DATE       = $(shell date -u '+%Y-%m-%d_%H:%M:%S%p')
LDFLAGS    = "\
-X github.com/prometheus/$(NAME)/vendor/github.com/prometheus/common/version.Version=$(VERSION) \
-X github.com/prometheus/$(NAME)/vendor/github.com/prometheus/common/version.Revision=OMD-Labs \
-X github.com/prometheus/$(NAME)/vendor/github.com/prometheus/common/version.Branch=$(BRANCH) \
-X github.com/prometheus/$(NAME)/vendor/github.com/prometheus/common/version.BuildUser=OMD-Labs \
-X github.com/prometheus/$(NAME)/vendor/github.com/prometheus/common/version.BuildDate=$(DATE) \
-s -w \
"

build:
	tar zxf $(SRC)
	export GOROOT=$(GOROOT) && export GOPATH=$(GOPATH) && PATH=$$GOROOT/bin:$$PATH && \
		go install -ldflags $(LDFLAGS) github.com/prometheus/$(NAME)/cmd/alertmanager && \
		go install -ldflags $(LDFLAGS) github.com/prometheus/$(NAME)/cmd/amtool

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(GOPATH)/bin/alertmanager $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(GOPATH)/bin/amtool $(DESTDIR)$(OMD_ROOT)/bin

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
	rm -rf $(GOPATH)

package: clean
	export GOROOT=$(GOROOT) && export GOPATH=$(GOPATH) && PATH=$$GOROOT/bin:$$PATH && \
		mkdir -p $(GOPATH)/src/github.com/prometheus/ && \
		cd $(GOPATH)/src/github.com/prometheus/ && \
		git clone --depth=1 --branch "v$(VERSION)" https://github.com/prometheus/$(NAME).git && \
		cd $(NAME)/cmd/$(NAME)/ && go get -d && \
		cd $(PWD) && \
		tar zcf $(SRC) $(GOFOLDER)/src/ --exclude=.git

