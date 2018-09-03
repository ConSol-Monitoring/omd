include ../../Makefile.omd

NAME       = grafana-thruk-datasource
VERSION    = master
SRC        = $(NAME)-$(VERSION).tar.gz

.PHONY: skel

build:

install:

skel:
	mkdir -p $(SKEL)/var/grafana/plugins
	tar zxf $(SRC) -C $(SKEL)/var/grafana/plugins
	mv $(SKEL)/var/grafana/plugins/$(NAME)-$(VERSION) $(SKEL)/var/grafana/plugins/pnp-rrd-datasource

clean:

upstream:
	rm -f $(SRC)
	wget https://github.com/sni/grafana-thruk-datasource/archive/master.tar.gz -O $(SRC)
