include ../../Makefile.omd

NAME       = promlens
VERSION    = 0.2.0
SRC        = $(NAME)-$(VERSION).linux-amd64

.PHONY: skel

build:
	tar zxf $(NAME)-$(VERSION).linux-amd64.tar.gz

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(NAME)-$(VERSION).linux-amd64/$(NAME) $(DESTDIR)$(OMD_ROOT)/bin

skel:
	mkdir -p $(SKEL)/var/promlens

clean:
	rm -rf $(SRC)

upstream: clean
	wget https://github.com/prometheus/promlens/releases/download/v$(VERSION)/$(SRC).tar.gz
