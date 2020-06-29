include ../../Makefile.omd

NAME       = grafana-pnp-datasource
VERSION    = 1.0.6
SRC        = $(NAME)-$(VERSION).tar.gz
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
	tar zxf $(SRC) -C $(SKEL)/var/grafana/plugins
	mv $(SKEL)/var/grafana/plugins/$(NAME)-$(VERSION) $(SKEL)/var/grafana/plugins/pnp-rrd-datasource

clean:
	rm -rf $(APINAME)-$(APIVERSION)

upstream:
	rm -f $(SRC)
	wget https://github.com/sni/grafana-pnp-datasource/archive/v$(VERSION).tar.gz -O $(SRC)
	rm -f $(APISRC)
	wget https://github.com/sni/pnp-metrics-api/archive/master.tar.gz -O $(APISRC)
