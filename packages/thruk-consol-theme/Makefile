include ../../Makefile.omd

SHELL   = /bin/bash
SRC     = consol-theme
NAME    = Consol
DEPENDS = thruk


build:
	cd $(SRC) && ln -sfn $$(realpath ../../thruk/thruk-*/.) Thruk
	make -C $(SRC) build
	rm -rf dest
	mkdir -p dest
	cp -rp $(SRC)/{images,stylesheets} dest/
	make -C $(SRC) clean

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/thruk/themes/themes-available/
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/thruk/themes/themes-available/$(NAME)
	cp -rp ./dest/{images,stylesheets} $(DESTDIR)$(OMD_ROOT)/share/thruk/themes/themes-available/$(NAME)/

skel:

clean:
	make -C $(SRC) clean
	rm -f $(SRC)/Thruk
	rm -f $(SRC)/base.css
	rm -rf dest
