include ../../Makefile.omd

SAMPLICATOR=samplicator-4230b82

build:
	tar xvzf $(SAMPLICATOR).tar.gz
	cd $(SAMPLICATOR) && \
	    ./autogen.sh; \
	    ./configure; \
	    make; \
	    strip samplicate

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	cp snmptrap_logger.sh \
	    $(DESTDIR)$(OMD_ROOT)/bin
	cp $(SAMPLICATOR)/samplicate $(DESTDIR)$(OMD_ROOT)/bin
	cp samplicate_watch $(DESTDIR)$(OMD_ROOT)/bin
	chmod 755 $(DESTDIR)$(OMD_ROOT)/bin/samplicate_watch
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/samplicate
	cp samplicate.service $(DESTDIR)$(OMD_ROOT)/share/samplicate
	cp samplicate_watch.service $(DESTDIR)$(OMD_ROOT)/share/samplicate
	-test -d /run/. && sed -i -e 's/\/var\/run\//\/run\//g' $(DESTDIR)$(OMD_ROOT)/share/samplicate/*.service
	cp README.systemd $(DESTDIR)$(OMD_ROOT)/share/samplicate
	# SNMPTRAPD mirror (001-snmptrapd-mirror)
	cp trap_targets snmptrapd_mirror_watch \
	    $(DESTDIR)$(OMD_ROOT)/bin
	chmod 755 $(DESTDIR)$(OMD_ROOT)/bin/trap_targets \
	    $(DESTDIR)$(OMD_ROOT)/bin/snmptrapd_mirror_watch
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/snmptrapd_mirror
	cp snmptrapd_mirror_watch.service \
	    $(DESTDIR)$(OMD_ROOT)/share/snmptrapd_mirror
	cp share/snmptrapd_mirror/README.snmptrapd \
	    share/snmptrapd_mirror/snmptrapd.conf.example \
	    $(DESTDIR)$(OMD_ROOT)/share/snmptrapd_mirror
	-test -d /run/. && sed -i -e 's/\/var\/run\//\/run\//g' $(DESTDIR)$(OMD_ROOT)/share/snmptrapd_mirror/*.service

skel:

clean:
	rm -rf $(SAMPLICATOR)
