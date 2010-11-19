include ../../Makefile.omd

NAME = check_mk
VERSION = 1.1.9i1
DIR = $(NAME)-$(VERSION)

.PHONY: skel

build:
	tar xzf $(DIR).tar.gz

install:
	export bindir='$(OMD_ROOT)/bin' ; \
	export checksdir='$(OMD_ROOT)/share/check_mk/checks' ; \
	export modulesdir='$(OMD_ROOT)/share/check_mk/modules' ; \
	export web_dir='$(OMD_ROOT)/share/check_mk/web' ; \
	export mibsdir='$(OMD_ROOT)/share/snmp/mibs' ; \
	export docdir='$(OMD_ROOT)/share/doc/check_mk' ; \
	export checkmandir='$(OMD_ROOT)/share/doc/check_mk/checks' ; \
	export agentsdir='$(OMD_ROOT)/share/check_mk/agents' ; \
	export agentslibdir='$(OMD_ROOT)/lib/check_mk_agent' ; \
	export nagios_binary='$(OMD_ROOT)/bin/nagios' ; \
	export check_icmp_path='$(OMD_ROOT)/lib/nagios/plugins/check_icmp' ; \
	export pnptemplates='$(OMD_ROOT)/share/check_mk/pnp-templates' ; \
	export livebackendsdir='$(OMD_ROOT)/share/check_mk/livestatus' ; \
	export libdir='$(OMD_ROOT)/lib/check_mk' ; \
	export confdir='$(OMD_ROOT)/skel/etc/check_mk' ; \
	export pnpconfdir='$(OMD_ROOT)/skel/etc/pnp4nagios' ; \
	export pnprraconf='$(OMD_ROOT)/share/check_mk/pnp-rraconf' ; \
	export apache_config_dir='/REMOVE/skel/etc/apache' ; \
	export agentsconfdir='/etc/check_mk' ; \
	export vardir='/REMOVE/var/lib/check_mk' ; \
	export nagios_config_file='/REMOVE/etc/nagios/nagios.cfg' ; \
	export nagconfdir='/REMOVE/etc/nagios/conf.d' ; \
	export htpasswd_file='/REMOVE/etc/nagios/htpasswd' ; \
	export nagios_startscript='/REMOVE/etc/init.d/nagios' ; \
	export nagpipe='/REMOVE/var/run/nagios/rw/nagios.cmd' ; \
	export rrddir='/REMOVE/var/lib/nagios/rrd' ; \
	export nagios_status_file='/REMOVE/var/spool/nagios/status.dat' ; \
	export livesock='/REMOVE/var/run/nagios/rw/live' ; \
	export checkmk_web_uri='/nag01/check_mk' ; \
	export nagiosurl='/nag01/nagios' ; \
	export cgiurl='/nag01/nagios/cgi-bin' ; \
	export pnp_url='/nag01/pnp4nagios/' ; \
	export enable_livestatus='no' ; \
	export nagios_auth_name='Nagios Access' ; \
	export nagiosuser='nagios' ; \
	export wwwgroup='nagios' ; \
	cd $(DIR) ; DESTDIR=$(DESTDIR) ./setup.sh --yes

	# Delete files we do not want to package
	rm -rf $(DESTDIR)/REMOVE
	rm -f $(OMD_ROOT)/skel/etc/check_mk/*-*.mk

	# Install special version of check_mk dealing with site specific defaults
	install -m 755 check_mk $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 lq       $(DESTDIR)$(OMD_ROOT)/bin

	# defaults.py for Multisite which redirects to site specific defaults
	install -m 644 defaults.py $(DESTDIR)$(OMD_ROOT)/share/check_mk/web/htdocs

skel:
	rm -f $(SKEL)/etc/check_mk/main.mk-*
	rm -f $(SKEL)/etc/check_mk/multisite.mk-*

clean:
	rm -rf check_mk-*.*.*[0-9]

# Adapt configuration files for skeleton from upstream version
upstream:
	# check_mk_templates.cfg -> enter correct URLs and paths
	tar xzf check_mk-$(VERSION).tar.gz --to-stdout check_mk-$(VERSION)/doc.tar.gz | \
          tar xzf - --to-stdout check_mk_templates.cfg | \
          sed -e 's-@CHECK_ICMP@-###ROOT###/lib/nagios/plugins/check_icmp-g' \
              -e 's-@BINDIR@-###ROOT###/bin-g' \
              -e 's-@VARDIR@-###ROOT###/var/check_mk-g' \
              -e 's-@PNPURL@-/###SITE###/pnp4nagios/-g' \
              -e 's-@CGIURL@-/###SITE###/nagios/cgi\-bin-g' > \
          skel/etc/nagios/conf.d/check_mk_templates.cfg

	# multisite.mk - replace nagiosadmin with omadmin
	tar xzf check_mk-$(VERSION).tar.gz --to-stdout check_mk-$(VERSION)/conf.tar.gz | \
          tar xzf - --to-stdout multisite.mk-$(VERSION) | \
          sed -e 's/nagiosadmin/omdadmin/g' \
              -e 's@^nagvis_base_url.*@nagvis_base_url = "/###SITE###/nagvis"@' \
               > skel/etc/check_mk/multisite.mk

	# Add correct version number
	sed -i "s/^check_mk_version.*/check_mk_version            = '$(VERSION)'/" skel/etc/check_mk/defaults
