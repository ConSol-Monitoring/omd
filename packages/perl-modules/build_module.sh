#!/bin/bash

PERL=$1
MODULE=$2
echo $MODULE

cd ..
eval $($PERL -Idist/lib/perl5 -Mlocal::lib=dist)
cd src

tar zxf $MODULE
dir=$(basename $MODULE | sed s/\.tar\.gz// )
cd $dir
if [ -f Build.PL ]; then
    $PERL Build.PL
    ./Build
    ./Build install
elif [ -f Makefile.PL ]; then
     echo "" | $PERL Makefile.PL
     make
     make install
else
    echo "no Build.PL or Makefile.PL found in $MODULE!"
    exit 1
fi
cd ..
rm -rf $dir
