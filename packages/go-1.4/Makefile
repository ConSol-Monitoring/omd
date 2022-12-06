include ../../Makefile.omd
#Downloadlink for tars: https://golang.org/dl/
VERSION  = 1.4.3

GO=
ifeq ("$(wildcard /usr/bin/go)","")
	GO=go
endif

build: $(GO)

go: clean
	tar xzf go$(VERSION).src.tar.gz
	cd go/src/ && CGO_ENABLED=0 ./make.bash

install:

skel:

clean:
	rm -rf go
