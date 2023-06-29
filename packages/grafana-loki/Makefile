include ../../Makefile.omd

NAME       = grafana-loki
VERSION    = 2.7.2
DIR        = loki-$(VERSION)
SRC        = $(DIR).tar.gz
GOPKG      = 1.20
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
	mkdir -p ./dest
	install -m 755 $(DIR)/cmd/loki/loki                     ./dest/loki
	install -m 755 $(DIR)/clients/cmd/promtail/promtail     ./dest/promtail
	install -m 755 $(DIR)/cmd/logcli/logcli                 ./dest/logcli
	install -m 755 $(DIR)/cmd/chunks-inspect/chunks-inspect ./dest/chunks-inspect
	rm -rf $(DIR)

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 ./dest/loki           $(DESTDIR)$(OMD_ROOT)/bin/loki
	install -m 755 ./dest/promtail       $(DESTDIR)$(OMD_ROOT)/bin/promtail
	install -m 755 ./dest/logcli         $(DESTDIR)$(OMD_ROOT)/bin/logcli
	install -m 755 ./dest/chunks-inspect $(DESTDIR)$(OMD_ROOT)/bin/chunks-inspect

skel:

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
