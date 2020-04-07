include ../../Makefile.omd

NAME       = grafana-loki
VERSION    = 1.4.1
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
		make loki promtail

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(DIR)/cmd/loki/loki         $(DESTDIR)$(OMD_ROOT)/bin/loki
	install -m 755 $(DIR)/cmd/promtail/promtail $(DESTDIR)$(OMD_ROOT)/bin/promtail

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
	sed -e 's=/tmp/loki/=var/loki/=g' -i skel/etc/loki/loki.yaml
	tar zcf $(SRC) loki-$(VERSION)
	$(MAKE) clean
