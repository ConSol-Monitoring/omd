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
    if [ $module = "Scalar::List::Utils" ]; then module="List::Util::XS";       fi
    if [ $module = "libwww::perl" ];        then module="LWP";                  fi
    if [ $module = "Template::Toolkit" ];   then module="Template";             fi
    if [ $module = "IO::stringy" ];         then module="IO::Scalar";           fi
    if [ $module = "TermReadKey" ];         then module="Term::ReadKey";        fi
    if [ $module = "Gearman" ];             then module="Gearman::Client";      fi
    if [ $module = "IO::Compress" ];        then module="IO::Compress::Base";   fi

    url=""
    if [ -s .cpan.cache ]; then
        url=`grep "^$module " .cpan.cache | awk '{ print $2 }'`
    fi
    if [ -z "$url" ]; then
        url=`wget -o wgetlog -O - "http://search.cpan.org/perldoc?$module" | grep '.tar.gz' | sed 's/>/\n/g' | grep '/CPAN' | sed 's/.*"\(\/CPAN.*\.gz\)".*/\1/g' | head -n 1`
        if [ -z $url ]; then
          echo "failed"
          cat wgetlog && rm wgetlog
          exit 1
        fi
        rm -f wgetlog
        echo "$module $url" >> .cpan.cache
    fi
    newmodule=`echo $url | sed -e 's/.*\///g'`
    if [ "$module" == "CPAN" ]; then
        echo "skipped"
    elif [ "$FILE" == "$newmodule" ]; then
        echo "no update available"
    else
        url="http://search.cpan.org$url"
        # verify we get the same module
        test1=`echo $module    | sed -e 's/\-[0-9\.]*\.tar\.gz//g' -e 's/\-/::/g'`
        test2=`echo $newmodule | sed -e 's/\-[0-9\.]*\.tar\.gz//g' -e 's/\-/::/g'`
        if [ $test2 = "libwww::perl" ]; then test2="LWP";                fi
        if [ $test2 = "IO::Compress" ]; then test2="IO::Compress::Base"; fi
        if [ "$test1" != "$test2" ]; then
            echo "-> manual: module name has changed to $newmodule ($test1 != $test2)"
        else
            echo "-> $newmodule"
            wget -q "$url"
            sed -i -e s/$FILE/$newmodule/g ../Makefile
            rm "$FILE"
        fi
    fi
done
