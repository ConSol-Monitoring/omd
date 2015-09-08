include ../../Makefile.omd
#Downloadlink for tars: https://golang.org/dl/
NAME     = go
VERSION  = 1.5
DIR      = $(NAME)-$(VERSION)

build:
	mkdir $(DIR)
	tar xzf $(DIR)*.tar.gz -C $(DIR)
	mv $(DIR)/go/* $(DIR) && rm -rf $(DIR)/go
	cd $(DIR)/src/ && ./make.bash

install:

skel:

clean:
	rm -rf $(DIR)
