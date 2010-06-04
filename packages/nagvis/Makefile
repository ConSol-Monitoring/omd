include ../../Makefile.omd

NAME = nagvis
VERSION = 1.5rc3
DIR = $(NAME)-$(VERSION)

.PHONY: skel

build:
	tar xzf $(DIR).tar.gz

install:
	cd $(DIR) ; ./install.sh

	# Delete files we do not want to package
	#rm -rf $(DESTDIR)/REMOVE

skel:
	# Give Apache write permissions on certain directories
	#chmod 770 $(SKEL)/var/check_mk/web
	#chmod 770 $(SKEL)/var/check_mk/logwatch

clean:
	rm -rf $(DIR)



