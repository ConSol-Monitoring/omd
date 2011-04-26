#!/bin/bash

. "###ROOT###/.profile"

# set omd environment
export CATALYST_CONFIG="###ROOT###/etc/thruk"

# check plugins symlinks
for link in `ls -1 ###ROOT###/etc/thruk/plugins/plugins-available/`; do
  target=`readlink ###ROOT###/etc/thruk/plugins/plugins-available/$link`
  if [ "$target" = "$link" ]; then
    rm ###ROOT###/etc/thruk/plugins/plugins-available/$link
    ln -sfn ###ROOT###/share/thruk/plugins/plugins-available/$link ###ROOT###/etc/thruk/plugins/plugins-available/$link
  fi
done

# execute fastcgi server
exec "###ROOT###/share/thruk/script/thruk_fastcgi.pl";
