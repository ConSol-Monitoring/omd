#!/bin/bash
MODULE=$1
PERL=$2
FORCE=$3

if [ -z $MODULE ]; then
    echo "module name missing";
    exit 1
fi

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
if [ "$MODNAME" = "TermReadKey" ]; then
    MODNAME="Term::ReadKey"
fi
if [ "$MODNAME" = "IO::Compress" ]; then
    MODNAME="IO::Compress::Base"
fi
if [ "$MODNAME" = "Term::ReadLine::Gnu" ]; then
    PRE_CHECK="use Term::ReadLine; "
fi
if [ "$MODNAME" = "Package::DeprecationManager" ]; then
    MODVERS="$MODVERS -deprecations => { blah => foo }"
fi
if [ "$MODNAME" = "DBD::Oracle" ]; then
    if [ -n "$ORACLE_HOME" ]; then
        if [ -f "$ORACLE_HOME/libclntsh.so" ]; then
            export LD_LIBRARY_PATH=$ORACLE_HOME
        else
            echo "skipped"
            exit 3
        fi
    else
        echo "skipped"
        exit 3
    fi
fi

MODFILE=`echo "$MODNAME.pm" | sed -e 's/::/\//g'`
result=`$PERL -MData::Dumper -e "$PRE_CHECK use $MODNAME $MODVERS; print Dumper \%INC" 2>&1`
rc=$?
if [ $rc = 0 ]; then
    echo $result | grep /dist/lib/perl5/ |  grep $MODFILE > /dev/null 2>&1
    rc=$?
fi
if [ "$FORCE" = "testonly" ]; then
  if [ "$rc" = "0" ]; then
    echo "ok"
    exit 2;
  else
    echo "failed"
    echo $result
    exit 1;
  fi
fi
if [ "$FORCE" = "no" -a "$rc" = "0" ]; then
  echo "already installed"
  exit 2;
fi

if [ ! -e $MODULE ]; then
    echo "error: $MODULE does not exist"
    exit 1;
fi

tar zxf $MODULE
dir=$(basename $MODULE | sed s/\.tar\.gz// )
cd $dir
printf "installing... "
if [ -f Build.PL ]; then
    $PERL Build.PL >> $LOG 2>&1
    if [ $? != 0 ]; then echo "error: $?"; cat $LOG; exit 1; fi
    ./Build >> $LOG 2>&1
    if [ $? != 0 ]; then echo "error: $?"; cat $LOG; exit 1; fi
    ./Build install >> $LOG 2>&1
    if [ $? != 0 ]; then echo "error: $?"; cat $LOG; exit 1; fi
elif [ -f Makefile.PL ]; then
    echo "" | $PERL Makefile.PL >> $LOG 2>&1
    if [ $? != 0 ]; then echo "error: $?"; cat $LOG; exit 1; fi
    make -j 4 >> $LOG 2>&1
    if [ $? != 0 ]; then echo "error: $?"; cat $LOG; exit 1; fi
    make install >> $LOG 2>&1
    if [ $? != 0 ]; then echo "error: $?"; cat $LOG; exit 1; fi
else
    echo "error: no Build.PL or Makefile.PL found in $MODULE!"
    exit 1
fi
cd ..
rm -rf $dir
echo "ok"
