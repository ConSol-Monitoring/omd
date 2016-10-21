include ../../Makefile.omd

NAME     = thruk-plugins
PLUGINS  = editor \
           omd \
           woshsh

.PHONY: skel

build:

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/thruk/plugins/plugins-available
	for plugin in $(PLUGINS); do \
		tar zxf thruk-plugin-$$plugin.tgz -C $(DESTDIR)$(OMD_ROOT)/share/thruk/plugins/plugins-available/; \
		mv $(DESTDIR)$(OMD_ROOT)/share/thruk/plugins/plugins-available/thruk-plugin-$$plugin-master $(DESTDIR)$(OMD_ROOT)/share/thruk/plugins/plugins-available/$$plugin; \
	done

skel:

clean:

packages:
	for plugin in $(PLUGINS); do \
		wget https://github.com/sni/thruk-plugin-$$plugin/archive/master.tar.gz -O thruk-plugin-$$plugin.tgz; \
	done
