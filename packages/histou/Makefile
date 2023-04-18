include ../../Makefile.omd

NAME        = histou
VERSION     = 0.4.3
SRC         = $(NAME)-$(VERSION).tar.gz
PWD         = $(shell pwd)
DIR         = $(NAME)

.PHONY: skel

build:
	tar zxf $(SRC) --exclude=.git
	#set -e ; for p in patches/*.patch ; do \
	#    echo "applying $$p..." ; \
	#    ( cd $(DIR) && patch -p1 -b -F 5 ) < $$p ; \
	#done

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/$(DIR)
	rsync -a $(DIR)/. --exclude=histou.js $(DESTDIR)$(OMD_ROOT)/share/$(DIR)/.
	sed -i s/'\x27histou.ini'/\$$_SERVER[\'OMD_ROOT\'].\'"\/etc\/histou\/histou.ini"/ $(DESTDIR)$(OMD_ROOT)/share/$(DIR)/index.php
	sed -i s/'\x27histou.ini'/\$$_SERVER[\'OMD_ROOT\'].\'"\/etc\/histou\/histou.ini"/ $(DESTDIR)$(OMD_ROOT)/share/$(DIR)/rule_examinant.php
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/grafana/public/dashboards/
	cp $(DIR)/histou.js $(DESTDIR)$(OMD_ROOT)/share/grafana/public/dashboards/histou.js

skel:
	sed -i 's#phpCommand = .*#phpCommand = "$(PHP_FCGI_BIN)"#' $(SKEL)/etc/histou/histou.ini

clean:
	rm -rf histou

package:
	git clone  --depth=1 --branch "master" https://github.com/Griesbacher/histou
	tar zcf $(SRC) --exclude=.git --exclude=histou/tests --exclude=histou/conf --exclude=histou/stylecheck.sh histou
	rm -rf histou
