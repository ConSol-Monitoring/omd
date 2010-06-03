include Makefile.omd

DESTDIR=$$(pwd)/destdir

omd: build

build:
	@set -e ; for p in packages/* ; do \
	    $(MAKE) -C $$p build ; \
        done

pack:
	rm -rf $(DESTDIR)
	@set -e ; for p in packages/* ; do \
            $(MAKE) -C $$p DESTDIR=$(DESTDIR) install ; \
        done
	tar czf omd-$(OMD_VERSION).tar.gz -C $(DESTDIR) .

clean:
	rm -rf $(DESTDIR)
	@for p in packages/* ; do \
            $(MAKE) -C $$p clean ; \
        done
	
	
	
	
	
	
	
