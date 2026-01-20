SHELL=/bin/bash
NAME=Consol
N_PREFIX=$(shell pwd)/node_modules
NODEVERSION=16
export PATH := $(shell ls -d1 ../../node/node-*/bin 2>/dev/null):$(PATH)

.PHONY: thruk

build: stylesheets/$(NAME).css

stylesheets/$(NAME).css: thruk node_modules src/$(NAME).css
	mkdir -p stylesheets
	NODE_ENV=production \
	N_PREFIX=$(N_PREFIX) \
		npx tailwindcss -o stylesheets/${NAME}.css --input ./src/${NAME}.css --postcss ./postcss.config.js --minify
	touch stylesheets/${NAME}.css

dev: thruk node_modules
	mkdir -p stylesheets
	NODE_ENV=dev \
	N_PREFIX=$(N_PREFIX) \
		npx tailwindcss -o stylesheets/${NAME}.css --input ./src/${NAME}.css --postcss ./postcss.config.js

watch: thruk node_modules
	mkdir -p stylesheets
	NODE_ENV=dev \
	N_PREFIX=$(N_PREFIX) \
		npx tailwindcss -o stylesheets/${NAME}.css --input ./src/${NAME}.css --postcss ./postcss.config.js --watch

thruk:
	test -e thruk || git clone https://github.com/sni/thruk.git
	test -h thruk || ( cd thruk && git pull )
	ln -fns $$(realpath thruk/themes/base.css) base.css

node_modules:
	N_PREFIX=$(N_PREFIX) npm i -D

clean:
	rm -rf \
		node_modules \
		package-lock.json \
		base.css \
		stylesheets
	test -h thruk || rm -rf thruk
