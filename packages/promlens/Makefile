include ../../Makefile.omd

NAME        = promlens
VERSION     = 0.3.0
SRC         = $(NAME)-$(VERSION)
GOPKG       = 1.19
GOVERSION   = $(shell grep ^VERSION ../go-${GOPKG}/Makefile | awk '{ print $$3 }')

NODE_PATH=$(shell realpath $$(ls -d1 ../node/node-v*/lib/node_modules/npm/node_modules)):$(shell pwd)/node_modules

.PHONY: skel

build:
	tar zxf $(SRC).tar.gz
	export GOROOT=$(shell pwd)/../go-$(GOPKG)/go-$(GOVERSION)/ && \
	export PATH=$$GOROOT/bin:$(shell realpath $$(ls -d1 ../node/node-v*/bin)):$$PATH && \
	export NODE_PATH=$(NODE_PATH) && \
		make -C $(SRC)

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(SRC)/$(NAME) $(DESTDIR)$(OMD_ROOT)/bin

skel:
	mkdir -p $(SKEL)/var/promlens

clean:
	rm -rf $(SRC)

upstream: clean
	wget https://github.com/prometheus/promlens/archive/refs/tags/v$(VERSION).tar.gz -O $(SRC).tar.gz
