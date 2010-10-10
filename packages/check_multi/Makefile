include ../../Makefile.omd

.PHONY: skel

NAME     = check_multi
VERSION  = 0.24
DIR      = $(NAME)-$(VERSION)
SITEVAR  = \\\$$ENV{OMD_SITE}
ROOTVAR  = \\\$$ENV{OMD_ROOT}

#CONFIGUREOPTS = \
#	--with-tmp_dir='\$$ENV{OMD_ROOTVAR}/tmp' \
#	--with-checkresults_dir='\$$ENV{OMD_ROOTVAR}/tmp/spool' \
#	--with-config_dir='\$$ENV{OMD_ROOTVAR}/etc/check_multi' \
#	--with-plugin_path='\$$ENV{OMD_ROOTVAR}/lib/nagios/plugins' \
#	--with-pnp_url='\$$ENV{OMD_SITEVAR}/pnp4nagios' \

# TODO
#--with-nagios-name=<nagios|icinga>       set nagios name (there might be some clones ;)) (default:nagios)
#--with-action_url="$(SITEVAR)/pnp4nagios/index.php/graph?host=\\\$$HOSTNAME\\\$$&srv=\\\$$SERVICEDESC\\\$$"
#--with-persistent=0
CONFIGUREOPTS = \
	--libexecdir="$(ROOTVAR)/lib/nagios/plugins" \
	--prefix="$(ROOTVAR)" \
	--with-action_mouseover=1 \
	--with-cancel_before_global_timeout=0 \
	--with-checkresults_dir="$(ROOTVAR)/tmp/nagios/checkresults" \
	--with-child_interval=0.0 \
	--with-child_timeout=10 \
	--with-client_perl="/usr/bin/perl" \
	--with-cmdfile_update_interval=86400 \
	--with-collapse=1 \
	--with-config_dir="$(ROOTVAR)/etc/$(NAME)" \
	--with-cumulate_ignore_zero=1 \
	--with-empty_output_is_unknown=1 \
	--with-ethtool="/sbin/ethtool" \
	--with-exec_open3=0 \
	--with-extended_perfdata=1 \
	--with-extinfo_in_status=0 \
	--with-feed_passive_autocreate=0 \
	--with-feed_passive_dir="$(ROOTVAR)/etc/$(NAME)/feed_passive" \
	--with-feed_passive_dir_permissions=0750 \
	--with-findbin=1 \
	--with-file_extension="cmd" \
	--with-ignore_missing_cmd_file=0 \
	--with-illegal_chars="\r" \
	--with-image_path="/nagios/images" \
	--with-indent=" " \
	--with-indent_label=1 \
	--with-livestatus=""$(ROOTVAR)/tmp/run/live" \
	--with-loose_perfdata=1 \
	--with-name="" \
	--with-nagios-user=$(id -nu) \
	--with-nagios-group=$(id -gu) \
	--with-no_checks_rc=3 \
	--with-notes_url="" \
	--with-objects_cache="$(ROOTVAR)/var/nagios/objects.cache" \
	--with-objects_cache_delimiter="," \
	--with-omd_environment=1 \
	--with-parent_timeout=60 \
	--with-plugin_path="$(ROOTVAR)/local/lib/nagios/plugins" \
	--with-pnp_url="$(SITEVAR)/pnp4nagios" \
	--with-pnp_version=0.6 \
	--with-report=13 \
	--with-signal_rc=3 \
	--with-snmp_community="public" \
	--with-snmp_port=161 \
	--with-status_dat=""$(ROOTVAR)/tmp/nagios/status.dat" \
	--with-style_plus_minus="" \
	--with-tag_notes_link="" \
	--with-tmp_dir="$(ROOTVAR)/tmp/check_multi" \

build:
	tar xzf $(NAME)-stable-$(VERSION).tar.gz
	cd $(DIR) ; ./configure $(CONFIGUREOPTS)
	$(MAKE) -C $(DIR) all

install:
	mkdir -p $(DESTDIR)$(OMD_ROOTVAR)/lib/nagios/plugins
	install -m 755 $(DIR)/plugins/check_multi $(DESTDIR)$(OMD_ROOTVAR)/lib/nagios/plugins
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/doc/check_multi
	install -m 644 $(DIR)/README $(DESTDIR)$(OMD_ROOT)/share/doc/check_multi

skel:
	# Optional target called to create additional files below skel

clean:
	rm -rf $(NAME)-$(VERSION)

test test-all test-checkresults test-feeds-passive test-livestatus test-statusdat:
	$(MAKE) build
	OMD_ROOT=/tmp/test OMD_SITE=test $(MAKE) -C $(DIR) $@

get:
	wget --no-clobber my-plugin.de/check_multi/check_multi-stable-$(VERSION).tar.gz

get-force:
	rm check_multi-stable-$(VERSION).tar.gz
	wget --no-clobber my-plugin.de/check_multi/check_multi-stable-$(VERSION).tar.gz

