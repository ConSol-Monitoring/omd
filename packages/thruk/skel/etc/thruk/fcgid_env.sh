#!/bin/bash

[ -e ###ROOT###/.profile ] && . ###ROOT###/.profile
[ -e ###ROOT###/.thruk   ] && . ###ROOT###/.thruk

# set omd environment
export CATALYST_CONFIG="###ROOT###/etc/thruk"

# execute fastcgi server
exec "###ROOT###/share/thruk/script/thruk_fastcgi.pl";
