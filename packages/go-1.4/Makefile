include ../../Makefile.omd
#Downloadlink for tars: https://golang.org/dl/
VERSION  = 1.4.3

build: clean
	tar xzf go$(VERSION).src.tar.gz
	cd go/src/ && CGO_ENABLED=0 ./make.bash

install:

skel:

clean:
	rm -rf go
