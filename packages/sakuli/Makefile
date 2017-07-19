include ../../Makefile.omd

NAME     = sakuli-setup
DIR = $(NAME)

build:
	tar xzf $(DIR).tar.gz

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/sakuli/
	rsync -a $(DIR) $(DESTDIR)$(OMD_ROOT)/share/sakuli/

skel:

clean:
