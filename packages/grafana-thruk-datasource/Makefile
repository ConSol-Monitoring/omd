include ../../Makefile.omd

NAME       = sni-thruk-datasource
VERSION    = 2.0.0
SRC        = $(NAME)-$(VERSION).zip

.PHONY: skel

build:

install:

skel:
	mkdir -p $(SKEL)/var/grafana/plugins
	unzip $(SRC) -d $(SKEL)/var/grafana/plugins

clean:

upstream:
	rm -f $(SRC)
	wget https://github.com/sni/grafana-thruk-datasource/releases/download/v$(VERSION)/$(NAME)-$(VERSION).zip -O $(SRC)
