#!/bin/bash

cd src
for MODULE in $*; do
    url=`wget -o wgetlog -O - "http://search.cpan.org/perldoc?$MODULE" | sed 's/>/\n/g' | grep '/CPAN' | sed 's/.*"\(\/CPAN.*\.gz\)".*/\1/g' | head -n 1`
    if [ -z $url ]; then
      echo "wget failed:"
      cat wgetlog && rm wgetlog
      exit 1
    fi
    url="http://search.cpan.org$url"
    echo "$url"
    wget -q "$url"
done
