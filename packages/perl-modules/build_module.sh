#!/bin/bash

MODULE=$1
PERL=$2
FORCE=$3

LOG="install.log"
printf "%-55s" "*** $MODULE"

if [ -z $FORCE ]; then
    FORCE="no"
fi
if [ -z $PERL ]; then
    PERL=/usr/bin/perl
fi

if [ -z $PERL5LIB ]; then
  cd ..
  eval $($PERL -Idist/lib/perl5 -Mlocal::lib=dist)
  cd src
fi

# the Scalar::List::Utils tarball contains List::Util::XS, so do a rewrite here
#PMOD=`echo $MODULE | sed -e 's/\-\([0-9].*\)\.tar\.gz/ \1/g' | sed -e 's/\-/::/g' | sed -e s/Scalar::List::Utils/List::Util::XS/g`
PMOD=`echo $MODULE | sed -e 's/\-\([0-9].*\)\.tar\.gz/ \1/g' | sed -e 's/\-/::/g'`
MODNAME=`echo $PMOD | awk '{ print $1 }'`
MODVERS=`echo $PMOD | awk '{ print $2 }'`

# add some exceptions
if [ "$MODNAME" = "Scalar::List::Utils" ]; then
    MODNAME="List::Util::XS"
fi
if [ "$MODNAME" = "libwww::perl" ]; then
    MODNAME="LWP"
fi
if [ "$MODNAME" = "Module::Install" ]; then
    MODNAME="inc::Module::Install"
fi
if [ "$MODNAME" = "Template::Toolkit" ]; then
    MODNAME="Template"
fi
if [ "$MODNAME" = "IO::stringy" ]; then
    MODNAME="IO::Scalar"
fi
if [ "$MODNAME" = "Package::DeprecationManager" ]; then
    MODVERS="$MODVERS -deprecations => { blah => foo }"
fi
if [ "$MODNAME" = "DBD::Oracle" ]; then
    if [ -n "$ORACLE_HOME" ]; then
        if [ -f "$ORACLE_HOME/libclntsh.so" ]; then
            export LD_LIBRARY_PATH=$ORACLE_HOME
        else
            exit 0
        fi
    else
        exit 0
    fi
fi

$PERL -e "use $MODNAME $MODVERS;" > /dev/null 2>&1
rc=$?
if [ "$FORCE" = "testonly" ]; then
  if [ "$rc" = "0" ]; then
    exit 0;
  else
    exit 1;
  fi
fi
if [ "$FORCE" = "no" -a "$rc" = "0" ]; then
  exit 0;
fi

if [ ! -e $MODULE ]; then
    echo "file: $MODULE does not exist"
    exit 1;
fi

tar zxf $MODULE
dir=$(basename $MODULE | sed s/\.tar\.gz// )
cd $dir
if [ -f Build.PL ]; then
    #$PERL Build.PL 2>&1 | tee -a $LOG | grep 'not found'
    $PERL Build.PL >> $LOG 2>&1
    if [ $? != 0 ]; then echo $?; cat $LOG; exit 1; fi
    ./Build >> $LOG 2>&1
    if [ $? != 0 ]; then echo $?; cat $LOG; exit 1; fi
    ./Build install >> $LOG 2>&1
    if [ $? != 0 ]; then echo $?; cat $LOG; exit 1; fi
elif [ -f Makefile.PL ]; then
    #echo "" | $PERL Makefile.PL 2>&1 | tee -a $LOG | grep 'not found'
    echo "" | $PERL Makefile.PL >> $LOG 2>&1
    if [ $? != 0 ]; then echo $?; cat $LOG; exit 1; fi
    make -j 4 >> $LOG 2>&1
    if [ $? != 0 ]; then echo $?; cat $LOG; exit 1; fi
    make install >> $LOG 2>&1
    if [ $? != 0 ]; then echo $?; cat $LOG; exit 1; fi
else
    echo "no Build.PL or Makefile.PL found in $MODULE!"
    exit 1
fi
cd ..
rm -rf $dir
