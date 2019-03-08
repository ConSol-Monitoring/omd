
AP=~/bin/ansible-playbook

screenshot_history: config
	ansible-playbook -i localhost, -c local screenshot_history.yml

gearman:
	ansible-playbook -i localhost, -c local mod-gearman.yml

gearman_proxy: gearman_proxy_install config

gearman_proxy_install:
	ansible-playbook -i localhost, -c local gearman-proxy.yml

config:
	ansible-playbook -i localhost, -c local coreconfig.yml

mysql: config
	ansible-playbook -i localhost, -c local mysql.yml

grafana:
	ansible-playbook -i localhost, -c local grafana.yml

pnp4nagios:
	ansible-playbook -i localhost, -c local pnp4nagios.yml
