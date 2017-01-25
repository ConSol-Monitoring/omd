include ../../Makefile.omd

PROMETHEUS=prometheus-1.5.0
NODEEXPORTER=node_exporter-0.13.0

.PHONY: skel

build:
	tar xzf $(PROMETHEUS).linux-amd64.tar.gz
	tar xzf $(NODEEXPORTER).linux-amd64.tar.gz

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(PROMETHEUS).linux-amd64/prometheus $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(PROMETHEUS).linux-amd64/promtool $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(NODEEXPORTER).linux-amd64/node_exporter $(DESTDIR)$(OMD_ROOT)/bin

skel:
	mkdir -p $(SKEL)/etc/prometheus
	#cp $(PROMETHEUS).linux-amd64/prometheus.yml $(SKEL)/etc/prometheus
	mkdir -p $(SKEL)/etc/prometheus/conf.d/custom
	echo "Use this dir for your hand-crafted configs." > $(SKEL)/etc/prometheus/conf.d/custom/README
	mkdir -p $(SKEL)/etc/prometheus/conf.d/dynamic
	echo "Use this dir for your automatically created configs. Use coshsh" > $(SKEL)/etc/prometheus/conf.d/dynamic/README
	cp -rp $(PROMETHEUS).linux-amd64/consoles $(SKEL)/etc/prometheus
	cp -rp $(PROMETHEUS).linux-amd64/console_libraries $(SKEL)/etc/prometheus
	mv $(SKEL)/etc/prometheus/consoles/index.html.example $(SKEL)/etc/prometheus/consoles/index.html
	sed -ri 's/index.html.example/index.html/g' $(SKEL)/etc/prometheus/console_libraries/menu.lib

clean:
	rm -rf $(PROMETHEUS).linux-amd64
	rm -rf $(NODEEXPORTER).linux-amd64
