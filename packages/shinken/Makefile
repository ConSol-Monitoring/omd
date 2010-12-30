include ../../Makefile.omd

NAME = shinken
VERSION = 0.4.1
DIR = $(NAME)-$(VERSION)

SHINKEN_FILE=$(DIR).tar.gz
SHINKEN_URL=http://sourceforge.net/projects/shinken/files/shinken-0.4.1.tar.gz
PYRO=Pyro-3.11
MP=multiprocessing-2.6.2.1
PYRO_FILE=$(PYRO).tar.gz
MP_FILE=$(MP).tar.gz
PYRO_URL=http://www.xs4all.nl/~irmen/pyro3/download/$(PYRO_FILE)
MP_URL=http://pypi.python.org/packages/source/m/multiprocessing/$(MP_FILE)

build:
	test -f ${SHINKEN_FILE} || wget $(SHINKEN_URL)
	tar xzf $(SHINKEN_FILE)
	#set -e ; for p in patches/*.dif ; do \
	#    echo "applying $$p..." ; \
	#    ( cd $(DIR) ; patch -p1 -b ) < $$p ; \
	#done
	test -f $(PYRO_FILE) || wget $(PYRO_URL)
	tar xzf $(PYRO_FILE)
	test -f $(MP_FILE) || wget $(MP_URL)
	tar xzf $(MP_FILE)


install:
	$(MAKE) installshinken
	$(MAKE) installpyro
	$(MAKE) installmp

installshinken:
	# bin/shinken-* startfiles
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(DIR)/bin/shinken-arbiter $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(DIR)/bin/shinken-broker $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(DIR)/bin/shinken-scheduler $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(DIR)/bin/shinken-poller $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(DIR)/bin/shinken-reactionner $(DESTDIR)$(OMD_ROOT)/bin

	# shinken py-files
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/shinken
	cp -r $(DIR)/shinken $(DESTDIR)$(OMD_ROOT)/lib/shinken

	install -m 755 merge-shinken-config $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 merge-shinken-specific-config $(DESTDIR)$(OMD_ROOT)/bin
  
installpyro:
	( cd $(PYRO) ; python setup.py install --prefix=$(DESTDIR)$(OMD_ROOT) --install-scripts=$(DESTDIR)$(OMD_ROOT)/tmp --install-data=$(DESTDIR)$(OMD_ROOT)/tmp )

installmp:
	( cd $(MP) ; PYTHONPATH=$(DESTDIR)$(OMD_ROOT)/lib/python python setup.py install --prefix=$(DESTDIR)$(OMD_ROOT) --install-scripts=$(DESTDIR)$(OMD_ROOT)/tmp --install-data=$(DESTDIR)$(OMD_ROOT)/tmp )

clean:
	rm -rf $(DIR)
	rm -rf $(PYRO)
	rm -rf $(MP)

