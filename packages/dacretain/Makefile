include ../../Makefile.omd

NAME     = dacretain

.PHONY: skel

build:

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 dacretain $(DESTDIR)$(OMD_ROOT)/bin
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/dacretain
	install -m 755 hooks/naemon-reload-post.dacretain $(DESTDIR)$(OMD_ROOT)/share/dacretain
	install -m 755 hooks/naemon-reload-pre.dacretain $(DESTDIR)$(OMD_ROOT)/share/dacretain
	install -m 755 hooks/naemon-stop-post.dacretain $(DESTDIR)$(OMD_ROOT)/share/dacretain
	install -m 755 hooks/naemon-stop-pre.dacretain $(DESTDIR)$(OMD_ROOT)/share/dacretain
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/doc/dacretain
	install -m 644 doc/README $(DESTDIR)$(OMD_ROOT)/share/doc/dacretain
	ln -s naemon-reload-post.dacretain $(DESTDIR)$(OMD_ROOT)/share/dacretain/naemon-start-post.dacretain

skel:

clean:
