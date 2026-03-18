include ../../Makefile.omd

# this packages is used to bootstrap the current go src
# usually go requires N-1 or N-2 as minimum go to build the current go
# from source. So the 1.26 should be able to build 1.26 - 1.28. Update
# theses binaries when the latest go release requires a newer version
# The packages itself then use the go-<version>
NAME     = go
VERSION  = 1.26.1
SHELL    = /bin/bash
DIR      = $(NAME)

ifeq ($(shell uname -m),x86_64)
SRC=go$(VERSION).linux-amd64.tar.xz
else ifeq ($(shell uname -m),aarch64)
SRC=go$(VERSION).linux-arm64.tar.xz
else
$(error arch $(shell uname -m ) not supported)
endif

build:
	tar xfJ $(SRC)

install:

skel:

clean:
	rm -rf $(DIR)

package:
	# download and repackage amd64
	wget "https://go.dev/dl/go$(VERSION).linux-amd64.tar.gz"
	tar xfz go$(VERSION).linux-amd64.tar.gz
	XZ_OPT=-8 tar cfJ go$(VERSION).linux-amd64.tar.xz $(DIR)
	rm -rf $(DIR)
	rm -rf go$(VERSION).linux-amd64.tar.gz
	# and for arm64
	wget "https://go.dev/dl/go$(VERSION).linux-arm64.tar.gz"
	tar xfz go$(VERSION).linux-arm64.tar.gz
	XZ_OPT=-8 tar cfJ go$(VERSION).linux-arm64.tar.xz $(DIR)
	rm -rf $(DIR)
	rm -rf go$(VERSION).linux-arm64.tar.xz

upstream: package
