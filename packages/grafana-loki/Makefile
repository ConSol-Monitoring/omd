include ../../Makefile.omd

NAME       = grafana-loki
VERSION    = 1.5.0
DIR        = loki-$(VERSION)
SRC        = $(DIR).tar.gz
GOPKG      = 1.14
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
		go build

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(DIR)/cmd/loki/loki         $(DESTDIR)$(OMD_ROOT)/bin/loki
	install -m 755 $(DIR)/cmd/promtail/promtail $(DESTDIR)$(OMD_ROOT)/bin/promtail
	install -m 755 $(DIR)/cmd/logcli/logcli     $(DESTDIR)$(OMD_ROOT)/bin/logcli
	install -m 755 $(DIR)/cmd/chunks-inspect/chunks-inspect     $(DESTDIR)$(OMD_ROOT)/bin/chunks-inspect

skel:

clean:
	rm -rf $(DIR)

package: clean
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
