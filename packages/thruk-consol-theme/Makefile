include ../../Makefile.omd

SHELL   = /bin/bash
SRC     = consol-theme
NAME    = Consol


build:
	cd $(SRC) && ln -sfn $$(realpath ../../thruk/thruk-*/.) Thruk
	make -C $(SRC) build

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/thruk/themes/themes-available/
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/thruk/themes/themes-available/$(NAME)
	cp -rp $(SRC)/{images,stylesheets} $(DESTDIR)$(OMD_ROOT)/share/thruk/themes/themes-available/$(NAME)/

skel:

clean:
	make -C $(SRC) clean
	rm -f $(SRC)/Thruk
	rm -f $(SRC)/base.css
