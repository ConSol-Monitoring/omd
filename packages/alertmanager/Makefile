include ../../Makefile.omd

ALERTMANAGER=alertmanager-0.5.1

.PHONY: skel

build:
	tar xzf $(ALERTMANAGER).linux-amd64.tar.gz

install:
	mkdir -p $(DESTDIR)$(OMD_ROOT)/bin
	install -m 755 $(ALERTMANAGER).linux-amd64/alertmanager $(DESTDIR)$(OMD_ROOT)/bin

skel:
	mkdir -p $(SKEL)/etc/alertmanager
	#cp $(PROMETHEUS).linux-amd64/alertmanager.yml $(SKEL)/etc/alertmanager
	mkdir -p $(SKEL)/etc/alertmanager/conf.d/custom
	echo "Use this dir for your hand-crafted configs." > $(SKEL)/etc/alertmanager/conf.d/custom/README
	mkdir -p $(SKEL)/etc/alertmanager/conf.d/dynamic
	echo "Use this dir for your automatically created configs. Use coshsh" > $(SKEL)/etc/alertmanager/conf.d/dynamic/README

clean:
	rm -rf $(ALERTMANAGER).linux-amd64
