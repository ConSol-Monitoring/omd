#!/bin/bash

. "###ROOT###/.profile"

# set omd environment
export CATALYST_CONFIG="###ROOT###/etc/thruk"

# execute fastcgi server
exec "###ROOT###/share/thruk/script/thruk_fastcgi.pl";
