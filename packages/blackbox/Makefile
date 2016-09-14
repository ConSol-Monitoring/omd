include ../../Makefile.omd

BLACKBOX=blackbox_exporter-0.2.0

.PHONY: skel

build:
	tar xzf $(BLACKBOX).linux-amd64.tar.gz

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(BLACKBOX).linux-amd64/blackbox_exporter $(DESTDIR)$(OMD_ROOT)/bin

skel:
	mkdir -p $(SKEL)/etc/blackbox_exporter
	cp $(PROMETHEUS).linux-amd64/blackbox.yml $(SKEL)/etc/blackbox_exporter
	#mkdir -p $(SKEL)/etc/blackbox_exporter/conf.d/custom
	#echo "Use this dir for your hand-crafted configs." > $(SKEL)/etc/blackbox_exporter/conf.d/custom/README
	#mkdir -p $(SKEL)/etc/blackbox_exporter/conf.d/dynamic
	#echo "Use this dir for your automatically created configs. Use coshsh" > $(SKEL)/etc/blackbox_exporter/conf.d/dynamic/README

clean:
	rm -rf $(BLACKBOX)
