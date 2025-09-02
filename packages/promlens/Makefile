include ../../Makefile.omd

NAME        = promlens
VERSION     = 0.3.0
SRC         = $(NAME)-$(VERSION)
GOPKG       = 1.23
GOVERSION   = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')
DEPENDS     = node

NODE_PATH=$(shell realpath $$(ls -d1 ../node/node-v*/lib/node_modules/npm/node_modules)):$(shell pwd)/node_modules
ifneq ($(DISTRO_CODE),el7)
  export NODE_OPTIONS=--openssl-legacy-provider
endif

.PHONY: skel

build:
	tar zxf $(SRC).tar.gz
	export GOROOT=$(shell pwd)/../go-$(GOPKG)/go-$(GOVERSION)/ && \
	export PATH=$$GOROOT/bin:$(shell realpath $$(ls -d1 ../node/node-v*/bin)):$$PATH && \
	export NODE_PATH=$(NODE_PATH) && \
		make -j 1 SKIP_GOLANGCI_LINT=1 -C $(SRC) build
	cp $(SRC)/$(NAME) ./$(NAME)
	strip ./$(NAME)
	$(UPX) ./$(NAME)
	rm -rf $(SRC)

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 ./$(NAME) $(DESTDIR)$(OMD_ROOT)/bin

skel:
	mkdir -p $(SKEL)/var/promlens

clean:
	rm -rf $(SRC)
	rm -f ./$(NAME)

upstream: clean
	wget https://github.com/prometheus/promlens/archive/refs/tags/v$(VERSION).tar.gz -O $(SRC).tar.gz
