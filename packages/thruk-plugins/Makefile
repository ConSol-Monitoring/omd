include ../../Makefile.omd

NAME     = thruk-plugins
PLUGINS  = woshsh \

CONSOLPLUGINS  = pansnaps \

.PHONY: skel

build:

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/thruk/plugins/plugins-available
	for plugin in $(PLUGINS) $(CONSOLPLUGINS); do \
		tar xfJ thruk-plugin-$$plugin.tar.xz -C $(DESTDIR)$(OMD_ROOT)/share/thruk/plugins/plugins-available/; \
		mv $(DESTDIR)$(OMD_ROOT)/share/thruk/plugins/plugins-available/thruk-plugin-$$plugin-master $(DESTDIR)$(OMD_ROOT)/share/thruk/plugins/plugins-available/$$plugin; \
	done

skel:

clean:

upstream: packages

packages:
	for plugin in $(PLUGINS); do \
		wget https://github.com/sni/thruk-plugin-$$plugin/archive/master.tar.gz -O thruk-plugin-$$plugin.tgz; \
	done
	for plugin in $(CONSOLPLUGINS); do \
		wget https://github.com/ConSol/thruk-plugin-$$plugin/archive/master.tar.gz -O thruk-plugin-$$plugin.tgz; \
	done
	# repackage with xz
	for FILE in $(PLUGINS) $(CONSOLPLUGINS); do \
		tar xzf thruk-plugin-$${FILE}.tgz; \
		rm -f thruk-plugin-$${FILE}.tgz; \
		XZ_OPT=-9 tar cfJ thruk-plugin-$${FILE}.tar.xz thruk-plugin-$${FILE}-master; \
		rm -rf thruk-plugin-$${FILE}-master; \
	done
