include ../../Makefile.omd

.PHONY: skel

NAME = check_multi
VERSION = 0.23
DIR = flackem-check_multi-39c9c7c

CONFIGUREOPTS = \
	--with-tmp_dir='\$$ENV{OMD_ROOT}/tmp' \
	--with-checkresults_dir='\$$ENV{OMD_ROOT}/tmp/spool' \
	--with-config_dir='\$$ENV{OMD_ROOT}/etc/check_multi' \
	--with-plugin_path='\$$ENV{OMD_ROOT}/lib/nagios/plugins' \
	--with-pnp_url='\$$ENV{OMD_SITE}/pnp4nagios' \

build:
	tar xzf $(NAME)-$(VERSION).tar.gz
	cd $(DIR) ; ./configure $(CONFIGUREOPTS)
	$(MAKE) -C $(DIR) all


install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins
	install -m 755 $(DIR)/plugins/check_multi $(DESTDIR)$(OMD_ROOT)/lib/nagios/plugins
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/doc/check_multi
	install -m 644 $(DIR)/README $(DESTDIR)$(OMD_ROOT)/share/doc/check_multi

skel:
	# Optional target called to create additional files below skel

clean:
	# Remove files created by build/install
