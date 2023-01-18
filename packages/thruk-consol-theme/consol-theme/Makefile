SHELL=/bin/bash
NAME=Consol
N_PREFIX=$(shell pwd)/node_modules
NODEVERSION=16
export PATH := $(shell ls -d1 ../../node/node-*/bin 2>/dev/null):$(PATH)

.PHONY: Thruk

build: stylesheets/$(NAME).css

stylesheets/$(NAME).css: Thruk node_modules src/$(NAME).css
	mkdir -p stylesheets
	NODE_ENV=production \
	N_PREFIX=$(N_PREFIX) \
		npx tailwindcss -o stylesheets/${NAME}.css --input ./src/${NAME}.css --postcss ./postcss.config.js --minify
	touch stylesheets/${NAME}.css

dev: Thruk node_modules
	mkdir -p stylesheets
	NODE_ENV=dev \
	N_PREFIX=$(N_PREFIX) \
		npx tailwindcss -o stylesheets/${NAME}.css --input ./src/${NAME}.css --postcss ./postcss.config.js

watch: Thruk node_modules
	mkdir -p stylesheets
	NODE_ENV=dev \
	N_PREFIX=$(N_PREFIX) \
		npx tailwindcss -o stylesheets/${NAME}.css --input ./src/${NAME}.css --postcss ./postcss.config.js --watch

Thruk:
	test -e Thruk || git clone https://github.com/sni/Thruk.git
	test -h Thruk || ( cd Thruk && git pull )
	ln -fns $$(realpath Thruk/themes/base.css) base.css

node_modules:
	N_PREFIX=$(N_PREFIX) \
		npm i -D \
		tailwindcss@latest \
		postcss@latest \
		autoprefixer@latest \
		postcss-import@latest \
		@tailwindcss/forms@latest \

clean:
	rm -rf \
		node_modules \
		package.json \
		package-lock.json \
		base.css \
		stylesheets
	test -h Thruk || rm -rf Thruk
