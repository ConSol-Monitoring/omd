include ../../Makefile.omd

NAME       = sni-thruk-datasource
VERSION    = 2.0.0
SRC        = $(NAME)-$(VERSION).zip

.PHONY: skel

build:

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/grafana/plugins-available
	unzip $(SRC) -d $(DESTDIR)$(OMD_ROOT)/share/grafana/plugins-available

skel:
	mkdir -p $(SKEL)/var/grafana/plugins
	ln -sfn ../../../share/grafana/plugins-available/$(NAME) $(SKEL)/var/grafana/plugins/$(NAME)

clean:

upstream:
	rm -f $(SRC)
	wget https://github.com/sni/grafana-thruk-datasource/releases/download/v$(VERSION)/$(NAME)-$(VERSION).zip -O $(SRC)
