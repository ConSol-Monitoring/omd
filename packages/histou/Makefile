include ../../Makefile.omd

NAME        = histou
VERSION     = 0.0.1
SRC         = $(NAME)-$(VERSION).tar.gz
PWD         = $(shell pwd)

build:

install:
	tar zxf $(SRC) -C $(DESTDIR)$(OMD_ROOT)/share --exclude=histou.js
	sed -i s/'\x27histou.ini'/\$$_SERVER[\'OMD_ROOT\'].\'"\/etc\/histou\/histou.ini"/ $(DESTDIR)$(OMD_ROOT)/share/histou/index.php
	tar zxf $(SRC) histou/histou.js
#	mv histou/histou.js $(DESTDIR)$(OMD_ROOT)/share/grafana/public/dashboards/histou.js
	cp omd-histou.js $(DESTDIR)$(OMD_ROOT)/share/grafana/public/dashboards/histou.js
	rm -rf histou

skel:

clean:

package:
	git clone https://github.com/Griesbacher/histou
	tar zcf $(SRC) histou --exclude=.git
	rm -rf histou
