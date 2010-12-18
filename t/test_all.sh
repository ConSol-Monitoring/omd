#!/bin/bash

if [ ! -d t ]; then
    echo "please run via 'make test' from the project directory"
    exit 1
fi

if [ $(id -u) -ne 0 ]; then
    echo "please run as root because we need to create test sites"
    exit 1
fi

# do we install a package?
if [ ! -z $PACKAGE ]; then
    echo "installing " `basename $PACKAGE`

    # Debian / Ubuntu
    if [ -x /usr/bin/apt-get  ]; then
        apt-get -y install `dpkg-deb --info $PACKAGE | grep Depends: | sed -e 's/Depends://' -e 's/debconf.*debconf-2.0,//' | tr -d ','`
        dpkg -i $PACKAGE

    # Centos
    elif [ -x /usr/bin/yum  ]; then
        /usr/bin/yum install -y --nogpgcheck $PACKAGE

    # Suse
    elif [ -x /usr/bin/zypper  ]; then
        /usr/bin/zypper install -n -l --no-recommends --no-gpg-checks $PACKAGE
    fi
fi

PERL_DL_NONLAZY=1 /usr/bin/env perl "-MExtUtils::Command::MM" "-e" "test_harness(0)" t/*.t
