#!/bin/bash

MODULES=$*
if [ -z $MODULES ]; then
    MODULES=*.tar.gz
fi

cd src
for FILE in $MODULES; do
    printf "%-55s" "$FILE"
    module=`echo $FILE | sed -e 's/\-[0-9\.]*\.tar\.gz//g' -e 's/\-/::/g'`

    # a few modules have borked package names
    if [ $module = "IO::Compress" ];        then module="IO::Compress::Base";   fi
    if [ $module = "IO::stringy" ];         then module="IO::Scalar";           fi
    if [ $module = "Scalar::List::Utils" ]; then module="List::Util::XS";       fi
    if [ $module = "TermReadKey" ];         then module="Term::ReadKey";        fi
    if [ $module = "libwww::perl" ];        then module="LWP";                  fi
    if [ $module = "Template::Toolkit" ];   then module="Template";             fi

    url=`wget -o wgetlog -O - "http://search.cpan.org/perldoc?$module" | grep '.tar.gz' | sed 's/>/\n/g' | grep '/CPAN' | sed 's/.*"\(\/CPAN.*\.gz\)".*/\1/g' | head -n 1`
    newmodule=`echo $url | sed -e 's/.*\///g'`
    if [ "$FILE" == "$newmodule" ]; then
        echo "no update available"
    else
        if [ -z $url ]; then
          echo "failed"
          cat wgetlog && rm wgetlog
          exit 1
        fi
        rm wgetlog
        url="http://search.cpan.org$url"
        echo "-> $newmodule"
        wget -q "$url"
        sed -i -e s/$FILE/$newmodule/g ../Makefile 
        rm "$FILE"
    fi
done
