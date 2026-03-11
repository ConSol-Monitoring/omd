include ../../Makefile.omd

NAME       = grafana-loki
CHANGELOG  = https://github.com/grafana/loki/blob/main/CHANGELOG.md
VERSION    = 3.3.1
DIR        = loki-$(VERSION)
SRC        = $(DIR).tar.gz
GOPKG      = 1.26
GOVERSION  = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
PWD        = $(shell pwd)
GOENV      = export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION) && export PATH=$$GOROOT/bin:$$PATH

.PHONY: skel

build:
	tar zxf $(SRC)
	$(GOENV) && \
		cd $(DIR) && \
		make loki promtail logcli
	$(GOENV) && \
		cd $(DIR)/cmd/chunks-inspect/ && \
		CGO_ENABLED=0 go build -ldflags="-s -w"
	mkdir -p ./dest
	install $(DIR)/cmd/loki/loki                     ./dest/loki
	install $(DIR)/clients/cmd/promtail/promtail     ./dest/promtail
	install $(DIR)/cmd/logcli/logcli                 ./dest/logcli
	install $(DIR)/cmd/chunks-inspect/chunks-inspect ./dest/chunks-inspect
	$(UPX) ./dest/*
	rm -rf $(DIR)

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 ./dest/*          $(DESTDIR)$(OMD_ROOT)/bin/
	install -m 755 loki.pre-update   $(DESTDIR)$(OMD_ROOT)/lib/omd/scripts/pre-update/loki
	install -m 755 loki.post-update  $(DESTDIR)$(OMD_ROOT)/lib/omd/scripts/post-update/loki

skel:
	sed -i 's/###GOPKG###/$(GOPKG)/' $(SKEL)/etc/init.d/loki $(SKEL)/etc/init.d/promtail

clean:
	rm -rf $(DIR)
	rm -rf ./dest

package: clean
	rm -f *.gz
	$(GOENV) go env
	wget "https://github.com/grafana/loki/archive/v$(VERSION).tar.gz"
	tar zxf v$(VERSION).tar.gz
	rm v$(VERSION).tar.gz
	$(GOENV) && \
	    cd loki-$(VERSION) && \
		make loki promtail
	echo "packageing"
	$(GOENV) && \
	    cd loki-$(VERSION) && \
		make clean
	cp $(DIR)/cmd/loki/loki-local-config.yaml skel/etc/loki/loki.yaml
	sed \
		-e 's=/tmp/loki/=var/loki/=g' \
		-e 's/http_listen_port: 3100/http_listen_port: ###CONFIG_LOKI_HTTP_PORT###/g' \
		-e 's/retention_deletes_enabled: false/retention_deletes_enabled: true/g' \
		-e 's/retention_period: 0s/retention_period: 840h/g' \
		-i skel/etc/loki/loki.yaml
	tar zcf $(SRC) loki-$(VERSION)
	$(MAKE) clean
