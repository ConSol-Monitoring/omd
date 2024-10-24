include ../../Makefile.omd

.PHONY: skel

NAME     = check_multi
BRANCH   = main
SRCDIR   = $(NAME)-$(BRANCH)
ROOTDIR  = \\\$$ENV{OMD_ROOT}
SITE     = \\\$$ENV{OMD_SITE}
TESTDIR  = ../../t/packages/check_multi/t
SHELL    = /bin/bash

# TODO
#--with-nagios-name=<nagios|icinga>       set nagios name (there might be some clones ;)) (default:nagios)
#--with-action_url="$(OMD_SITE)/pnp4nagios/index.php/graph?host=\\\$$HOSTNAME\\\$$&srv=\\\$$SERVICEDESC\\\$$"
CONFIGUREOPTS = \
	--libexecdir="$(ROOTDIR)/lib/monitoring-plugins" \
	--prefix="$(ROOTDIR)" \
	--with-action_mouseover=1 \
	--with-add_tag_to_list_entries=0 \
	--with-cancel_before_global_timeout=0 \
	--with-checkresults_dir="$(ROOTDIR)/tmp/naemon/checkresults" \
	--with-child_interval=0.0 \
	--with-child_timeout=11 \
	--with-client_perl="/usr/bin/perl" \
	--with-cmdfile_update_interval=86400 \
	--with-collapse=1 \
	--with-complain_unknown_macros=1 \
	--with-config_dir="$(ROOTDIR)/etc/$(NAME)" \
	--with-cumulate_ignore_zero=1 \
	--with-cumulate_max_rows=5 \
	--with-empty_output_is_unknown=1 \
	--with-ethtool="/sbin/ethtool" \
	--with-exec_open3=0 \
	--with-extended_perfdata=1 \
	--with-extinfo_in_status=0 \
	--with-feed_passive_autocreate=0 \
	--with-feed_passive_dir="$(ROOTDIR)/etc/$(NAME)/feed_passive" \
	--with-feed_passive_dir_permissions=0750 \
	--with-findbin=1 \
	--with-file_extension="cmd" \
    --with-history_non_numerical_value="complain" \
	--with-html_ascii_notification=0 \
	--with-ignore_missing_cmd_file=0 \
	--with-illegal_chars="\r" \
	--with-image_path="/$(SITE)/naemon/images" \
	--with-indent=" " \
	--with-indent_label=1 \
	--with-livestatus="$(ROOTDIR)/tmp/run/live" \
	--with-loose_perfdata=1 \
    --with-map_host_down_state_to=2 \
    --with-map_host_unreachable_state_to=3 \
	--with-name="" \
	--with-nagios-user=$(SITE) \
	--with-nagios-group=$(SITE) \
	--with-no_checks_rc=3 \
	--with-notes_url="" \
	--with-objects_cache="$(ROOTDIR)/var/naemon/objects.cache" \
	--with-objects_cache_delimiter="," \
	--with-omd_environment=1 \
	--with-parent_timeout=60 \
	--with-perfdata_pass_through=0 \
	--with-persistent=0 \
	--with-plugin_path="$(ROOTDIR)/lib/monitoring-plugins" \
	--with-pnp_add2url="" \
	--with-pnp_url="/$(SITE)/pnp4nagios" \
	--with-pnp_version=0.6 \
	--with-report=13 \
	--with-report_inherit_mask=-1 \
	--with-signal_rc=3 \
	--with-snmp_community="public" \
	--with-snmp_port=161 \
	--with-status_dat="$(ROOTDIR)/tmp/nagios/status.dat" \
	--with-style_plus_minus="" \
	--with-tag_notes_link="" \
	--with-target="_self" \
	--with-tmp_dir="$(ROOTDIR)/tmp/check_multi" \
	--with-tmp_dir_permissions=01777 \
	--with-tmp_etc="$(ROOTDIR)/tmp/check_multi/etc" \

build:
	tar zxf $(NAME)-$(BRANCH).tar.gz
	cd $(SRCDIR) ; ./configure $(CONFIGUREOPTS)
	$(MAKE) -C $(SRCDIR) all

install:
	#--- plugin
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins
	install -m 755 $(SRCDIR)/plugins/check_multi $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins

	#--- allow to find testdir in plugin directory
	test -L check_multi || ln -s $(SRCDIR) check_multi

skel:
	# Optional target called to create additional files below skel

clean:
	rm -rf $(SRCDIR)

test:
	$(MAKE) build && $(MAKE) install

package: clean
	rm -f $(NAME)-$(BRANCH).tar.gz
	wget "https://github.com/ConSol/check_multi/archive/refs/heads/$(BRANCH).tar.gz" -O $(NAME)-$(BRANCH).tar.gz
	tar zxf $(NAME)-$(BRANCH).tar.gz
	rm $(NAME)-$(BRANCH).tar.gz
	rm -rf $(NAME)-$(BRANCH)/doc
	tar cf $(NAME)-$(BRANCH).tar $(NAME)-$(BRANCH)
	gzip -9 $(NAME)-$(BRANCH).tar
	rm -rf $(NAME)-$(BRANCH)
