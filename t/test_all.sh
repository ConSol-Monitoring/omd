#!/bin/bash

if [ ! -d t ]; then
    echo "please run via 'make test' from the project directory"
    exit 1
fi

if [ $(id -u) -ne 0 ]; then
    echo "please run as root because we need to create test sites"
    exit 1
fi

if [ "$1" = "-t" ]; then
    TEST_TIMER=1
    shift
fi

export PATH="$PATH:/usr/sbin"

# do we install a package?
if [ ! -z "$OMD_PACKAGE" ]; then
    echo "###################################################################"

    OMD_PACKAGE=`ls -1 $OMD_PACKAGE | grep -v debug | head -n 1`

    if [ ! -e "$OMD_PACKAGE" ]; then
        echo "cannot install $OMD_PACKAGE: no such file"
    fi

    echo "installing " `basename $OMD_PACKAGE`

    # Debian / Ubuntu
    if [ -x /usr/bin/apt-get  ]; then
        apt-get -qq update
        DEBIAN_FRONTEND=noninteractive apt-get -q -y --no-install-recommends install $OMD_PACKAGE

    # Centos
    elif [ -x /usr/bin/yum  ]; then
        # remove version if alread installed
        /usr/bin/yum install -y --nogpgcheck $OMD_PACKAGE

    # Suse
    elif [ -x /usr/bin/zypper  ]; then
        # remove version if alread installed
        /usr/bin/zypper --quiet --non-interactive --no-gpg-checks install $OMD_PACKAGE
    fi

    rc=$?
    if [ $rc -ne 0 ]; then
        echo "Package installation failed, cannot run tests..."
        exit 1
    fi
fi

# set perl environment
PERLARCH=$(perl -e 'use Config; print $Config{archname}')
export PERL5LIB="/omd/versions/default/lib/perl5/lib/perl5/${PERLARCH}:/omd/versions/default/lib/perl5/lib/perl5:$PERL5LIB"

if [ -z $OMD_BIN ]; then
    OMD_BIN=/usr/bin/omd
fi

echo "###################################################################"
echo "running tests..."
TESTS=t/*.t
VERBOSE="0"
if [ ! -z $1 ]; then
  TESTS=$*
  VERBOSE="1"
fi

if [ "x$TEST_TIMER" != "x" ]; then
    for file in $TESTS; do
        printf "%-60s" $file
        output=$(OMD_BIN=$OMD_BIN PERL_DL_NONLAZY=1 /usr/bin/time -f %e /usr/bin/env perl "-MExtUtils::Command::MM" "-e" "test_harness($VERBOSE)" $file 2>&1)
        if [ $? != 0 ]; then
            printf "% 8s \n" "FAILED"
            echo "$output"
        else
            time=$(echo "$output" | tail -n1)
            printf "% 8ss\n" $time
        fi
    done
    exit
fi

OMD_BIN=$OMD_BIN PERL_DL_NONLAZY=1 /usr/bin/env perl "-MExtUtils::Command::MM" "-e" "test_harness($VERBOSE)" $TESTS
