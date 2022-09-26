include ../../Makefile.omd

NAME       = sni-pnp-datasource
VERSION    = 2.0.0
SRC        = $(NAME)-$(VERSION).zip
APINAME    = pnp-metrics-api
APIVERSION = master
APISRC     = $(APINAME)-$(APIVERSION).tar.gz

.PHONY: skel

build:
	tar zxf $(APISRC)

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/pnp4nagios/htdocs/application/controllers
	install -m 0644 $(APINAME)-$(APIVERSION)/application/controller/api.php $(DESTDIR)$(OMD_ROOT)/share/pnp4nagios/htdocs/application/controllers/

skel:
	mkdir -p $(SKEL)/var/grafana/plugins
	unzip $(SRC) -d $(SKEL)/var/grafana/plugins
	mv $(SKEL)/var/grafana/plugins/$(NAME) $(SKEL)/var/grafana/plugins/pnp-rrd-datasource

clean:
	rm -rf $(APINAME)-$(APIVERSION)

upstream:
	rm -f $(SRC)
	wget https://github.com/sni/grafana-pnp-datasource/releases/download/v$(VERSION)/$(NAME)-$(VERSION).zip -O $(SRC)
	rm -f $(APISRC)
	wget https://github.com/sni/pnp-metrics-api/archive/master.tar.gz -O $(APISRC)
