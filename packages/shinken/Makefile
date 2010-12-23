include ../../Makefile.omd

NAME = shinken
VERSION = 0.4.1
DIR = $(NAME)-$(VERSION)

build:
	tar xzf $(DIR).tar.gz
	#set -e ; for p in patches/*.dif ; do \
	#    echo "applying $$p..." ; \
	#    ( cd $(DIR) ; patch -p1 -b ) < $$p ; \
	#done


install:
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
  
clean:
	rm -rf $(DIR)
