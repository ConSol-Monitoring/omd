include ../../Makefile.omd

NAME        = histou
CHANGELOG   = https://github.com/ConSol-Monitoring/histou/blob/master/CHANGELOG.md
VERSION     = 0.6.2
SRC         = $(NAME)-$(VERSION).tar.gz
PWD         = $(shell pwd)
DIR         = $(NAME)
# GIT TAG is set automatically by "make upstream" or "make package"
GIT_TAG     = v0.6.2

.PHONY: skel

build:
	tar zxf $(SRC) --exclude=.git

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/$(DIR)
	rsync -a $(DIR)/. --exclude=histou.js $(DESTDIR)$(OMD_ROOT)/share/$(DIR)/.
	sed -i s/'\x27histou.ini'/\$$_SERVER[\'OMD_ROOT\'].\'"\/etc\/histou\/histou.ini"/ $(DESTDIR)$(OMD_ROOT)/share/$(DIR)/index.php
	sed -i s/'\x27histou.ini'/\$$_SERVER[\'OMD_ROOT\'].\'"\/etc\/histou\/histou.ini"/ $(DESTDIR)$(OMD_ROOT)/share/$(DIR)/rule_examinant.php
	mkdir -p $(DESTDIR)$(OMD_ROOT)/share/grafana/public/dashboards/
	cp $(DIR)/histou.js $(DESTDIR)$(OMD_ROOT)/share/grafana/public/dashboards/histou.js
	# install remaining templates
	install templates/*.php $(DESTDIR)$(OMD_ROOT)/share/histou/templates/default/

skel:
	sed -i 's#phpCommand = .*#phpCommand = "$(PHP_FCGI_BIN)"#' $(SKEL)/etc/histou/histou.ini

clean:
	rm -rf histou

package:
	rm -f $(NAME)-*.gz
	git clone  --depth=1 --branch "master" https://github.com/ConSol/histou
	cd histou && git fetch -q --tags --depth=1
	cd histou && sed -i $(PWD)/Makefile -e 's/^GIT_TAG.*$$/GIT_TAG     = '$$(git describe --always --tags)'/g'
	cd histou && sed -i $(PWD)/Makefile -e 's/^VERSION.*$$/VERSION     = '$$(git tag -l | tail -n 1 | sed -e 's/^v//')'/g'
	tar zcf $(NAME)-$$(cd histou && git tag -l | tail -n 1 | sed -e 's/^v//').tar.gz \
		--exclude=.git \
		--exclude=histou/tests \
		--exclude=histou/conf \
		--exclude=histou/stylecheck.sh \
		--exclude=histou/wheel_animation_example.gif \
		--exclude=histou/circle.yml \
		--exclude=histou/notes.txt \
		histou
	rm -rf histou

upstream: package
