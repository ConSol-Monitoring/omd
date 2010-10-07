#!/bin/bash

MODULE=$1
PERL=$2
FORCE=$3

LOG="install.log"
echo "*** $MODULE" >&2

#if [ -z $FORCE ]; then
#    FORCE=0
#fi
if [ -z $PERL ]; then
    PERL=/usr/bin/perl
fi

cd ..
eval $($PERL -Idist/lib/perl5 -Mlocal::lib=dist)
cd src

#PMOD=`echo $MODULE | sed -e 's/\-[0-9]\..*gz//g' | sed -e 's/\-/::/g'`
#$PERL -e "use $PMOD;" > /dev/null 2>&1
#if [ $FORCE == 0 -a $? == 0 ]; then
#  exit
#fi

tar zxf $MODULE
dir=$(basename $MODULE | sed s/\.tar\.gz// )
cd $dir
if [ -f Build.PL ]; then
    $PERL Build.PL 2>&1 | tee -a $LOG | grep 'not found'
    #if [ $? != 0 ]; then cat $LOG; exit 1; fi
    ./Build >> $LOG 2>&1
    #if [ $? != 0 ]; then cat $LOG; exit 1; fi
    ./Build install >> $LOG 2>&1
    #if [ $? != 0 ]; then cat $LOG; exit 1; fi
elif [ -f Makefile.PL ]; then
    echo "" | $PERL Makefile.PL 2>&1 | tee -a $LOG | grep 'not found'
    #if [ $? != 0 ]; then cat $LOG; exit 1; fi
    make >> $LOG 2>&1
    #if [ $? != 0 ]; then cat $LOG; exit 1; fi
    make install >> $LOG 2>&1
    #if [ $? != 0 ]; then cat $LOG; exit 1; fi
else
    echo "no Build.PL or Makefile.PL found in $MODULE!"
    exit 1
fi
cd ..
rm -rf $dir
