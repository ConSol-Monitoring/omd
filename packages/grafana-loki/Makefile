include ../../Makefile.omd

NAME       = grafana-loki
CHANGELOG  = https://github.com/grafana/loki/blob/main/CHANGELOG.md
VERSION    = 3.6.7
DIR        = loki-$(VERSION)
SRC        = $(DIR).tar.xz
GOPKG      = 1.26
GOVERSION  = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
PWD        = $(shell pwd)
GOENV      = export GOROOT=$(PWD)/../go-$(GOPKG)/go-$(GOVERSION) && export PATH=$$GOROOT/bin:$$PATH

.PHONY: skel

build:
	tar xfJ $(SRC)
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
	echo "packaging"
	$(GOENV) && \
	    cd loki-$(VERSION) && \
		make clean
	cp $(DIR)/cmd/loki/loki-local-config.yaml skel/etc/loki/loki.yaml
	sed \
		-e 's=/tmp/loki/*=var/loki=g' \
		-e 's/http_listen_port: 3100/http_listen_port: $${CONFIG_LOKI_HTTP_PORT:-3100}/g' \
		-e 's/grpc_listen_port: 9096/grpc_listen_port: $${CONFIG_LOKI_GRPC_PORT:-9096}/g' \
		-e 's/log_level: debug/log_level: info/g' \
		-e 's/#analytics:/analytics:/g' \
		-e 's/# *reporting_enabled: false/  reporting_enabled: false/g' \
		-e 's/retention_deletes_enabled: false/retention_deletes_enabled: true/g' \
		-e 's/retention_period: 0s/retention_period: $${CONFIG_LOKI_RETENTION:-32d}/g' \
		-e 's=alertmanager_url: http://localhost:9093=alertmanager_url: http://$${CONFIG_ALERTMANAGER_TCP_ADDR:-127.0.0.1}:$${CONFIG_ALERTMANAGER_TCP_PORT:-9093}=g' \
		-e 's=loki_address: localhost:3100=loki_address: localhost:$${CONFIG_LOKI_HTTP_PORT:-3100}=g' \
		-i skel/etc/loki/loki.yaml
	# remove some heavy but unused files to reduce the tarball size
	rm -rf $(DIR)/docs
	rm -rf loki-$(DIR)/operator
	find $(DIR)/ -type d -name testdata | xargs -r rm -rf
	find $(DIR)/ -type d -name test_fixtures | xargs -r rm -rf
	find $(DIR)/ -name \*_windows\*.go -delete
	find $(DIR)/ -name \*_darwin\*.go -delete
	find $(DIR)/ -name \*_freebsd\*.go -delete
	find $(DIR)/ -name \*_openbsd\*.go -delete
	find $(DIR)/ -name \*_netbsd\*.go -delete
	find $(DIR)/ -name \*_riscv\*.go -delete
	find $(DIR)/ -name \*_s390x\*.go -delete
	find $(DIR)/ -name \*_ppc64le\*.go -delete
	find $(DIR)/ -name \*_arm.go -delete
	find $(DIR)/ -name \*_386\*.go -delete
	find $(DIR)/ -name \*_loong64\*.go -delete
	find $(DIR)/ -name \*_test.go -delete
	find $(DIR)/ -name README.md -delete
	find $(DIR)/ -name CONTRIBUTING.md -delete
	find $(DIR)/ -name CHANGELOG.md -delete
	find $(DIR)/ -name storage.replay -delete
	XZ_OPT=-8 tar cfJ $(SRC) $(DIR)
	$(MAKE) clean

upstream: package
