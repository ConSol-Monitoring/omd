include ../../Makefile.omd

NAME       = grafana-thruk-datasource
VERSION    = 1.0.4
SRC        = $(NAME)-$(VERSION).tar.gz

.PHONY: skel

build:

install:

skel:
	mkdir -p $(SKEL)/var/grafana/plugins
	tar zxf $(SRC) -C $(SKEL)/var/grafana/plugins
	mv $(SKEL)/var/grafana/plugins/$(NAME)-$(VERSION) $(SKEL)/var/grafana/plugins/sni-thruk-datasource

clean:

upstream:
	rm -f $(SRC)
	wget https://github.com/sni/grafana-thruk-datasource/archive/v$(VERSION).tar.gz -O $(SRC)
