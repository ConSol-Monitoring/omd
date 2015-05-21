include ../../Makefile.omd

NAME     = go
VERSION  = 1.4
DIR      = $(NAME)-$(VERSION)

build: clean
	mkdir $(DIR)
	tar xzf $(DIR)*.tar.gz -C $(DIR)
	cd $(DIR)/src/ && ./make.bash

install:

skel:

clean:
	rm -rf $(DIR)
