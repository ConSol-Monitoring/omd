include ../../Makefile.omd

NAME        = histou
VERSION     = 0.0.1
SRC         = $(NAME)-$(VERSION).tar.gz
PWD         = $(shell pwd)

build:

install:
	tar zxf $(SRC) -C $(DESTDIR)$(OMD_ROOT)/share --exclude=histou.js
	mv $(DESTDIR)$(OMD_ROOT)/share/histou/histou.ini.example $(DESTDIR)$(OMD_ROOT)/share/histou/histou.ini
	sed -i '/influxdbUrl =/c\influxdbUrl = "http://127.0.0.1:8086/query?db=nagflux"' $(DESTDIR)$(OMD_ROOT)/share/histou/histou.ini
	tar zxf $(SRC) histou/histou.js
	mv histou/histou.js $(DESTDIR)$(OMD_ROOT)/share/grafana/public/dashboards/histou.js
	rm -rf histou

skel:

clean:

package:
	git clone https://github.com/Griesbacher/histou
	tar zcf $(SRC) histou --exclude=.git
	rm -rf histou
