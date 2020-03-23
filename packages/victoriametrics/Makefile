include ../../Makefile.omd

NAME       = victoriametrics
VERSION    = v1.34.0
PWD        = $(shell pwd)

.PHONY: skel


build:
	echo "nothing to build, just install tars from git"
	#bash get_victoriametrics $(VERSION) download $(PWD)

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	bash get_victoriametrics $(VERSION) extract . $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 *cron* $(DESTDIR)$(OMD_ROOT)/bin

skel:

clean:

package: 
	bash get_victoriametrics $(VERSION) download .
