include ../../Makefile.omd

NAME     = node
VERSION  = 20.6.1
SHELL    = /bin/bash

ifeq ($(DISTRO_CODE),el7)
  VERSION  = 16.17.1
endif

ifeq ($(shell uname -m),x86_64)
DIR=$(NAME)-v$(VERSION)-linux-x64
else ifeq ($(shell uname -m),aarch64)
DIR=$(NAME)-v$(VERSION)-linux-arm64
else
$(error arch $(shell uname -m ) not supported)
endif

.PHONY: skel

build:
	rm -rf $(DIR)
	tar Jxvf $(DIR).tar.xz

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)
	rsync -a $(DIR)/{bin,include,lib,share} $(DESTDIR)$(OMD_ROOT)

skel:

clean:
	rm -rf $(DIR)

package:
	wget "https://nodejs.org/dist/v$(VERSION)/$(NAME)-v$(VERSION)-linux-x64.tar.xz"
	wget "https://nodejs.org/dist/v$(VERSION)/$(NAME)-v$(VERSION)-linux-arm64.tar.xz"

