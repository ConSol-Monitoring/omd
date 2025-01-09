include ../../Makefile.omd

NAME       = upx
VERSION    = 4.2.4
DIR        = $(NAME)-$(VERSION)-src
SRC        = $(DIR).tar.xz

.PHONY: skel

build:
	tar Jxf $(SRC)
	make -C $(DIR)
	mkdir -p dest
	install -m 0755 $(DIR)/build/release/upx dest/
	rm -rf $(DIR)

install:

skel:

clean:
	rm -rf $(DIR)
	rm -rf ./dest

