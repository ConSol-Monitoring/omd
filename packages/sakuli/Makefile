include ../../Makefile.omd

NAME = sakuli-setup
DIR = setup

build:
	tar xzf sakuli-setup.tgz

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/sakuli/
	rsync -a $(DIR) $(DESTDIR)$(OMD_ROOT)/share/sakuli/

skel:

clean:
	rm -rf $(DIR)
