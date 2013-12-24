#!/bin/bash

if [ ! -d t ]; then
    echo "please run via 'make test' from the project directory"
    exit 1
fi

if [ $(id -u) -ne 0 ]; then
    echo "please run as root because we need to create test sites"
    exit 1
fi

export PATH="$PATH:/usr/sbin"

# do we install a package?
if [ ! -z "$OMD_PACKAGE" ]; then
    echo "###################################################################"

    OMD_PACKAGE=`ls -1 $OMD_PACKAGE | head -n 1`

    if [ ! -e "$OMD_PACKAGE" ]; then
        echo "cannot install $OMD_PACKAGE: no such file"
    fi

    echo "installing " `basename $OMD_PACKAGE`

    # Debian / Ubuntu
    if [ -x /usr/bin/apt-get  ]; then
        VERSION=`dpkg-deb -W --showformat='${Package}\n' $OMD_PACKAGE | sed -e 's/^omd-//'`
        DEPENDS=`dpkg-deb -W --showformat='${Depends}\n' $OMD_PACKAGE | sed -e 's/debconf.*debconf-2.0,//' | tr -d ','`
        apt-get -qq update && \
        DEBIAN_FRONTEND=noninteractive apt-get -q -y --no-install-recommends install $DEPENDS && \
        dpkg -i $OMD_PACKAGE && \
        update-alternatives --set omd /omd/versions/$VERSION

    # Centos
    elif [ -x /usr/bin/yum  ]; then
        # remove version if alread installed
        /usr/bin/yum remove -y `rpm -qp $OMD_PACKAGE`
        /usr/bin/yum install -y --nogpgcheck $OMD_PACKAGE

    # Suse
    elif [ -x /usr/bin/zypper  ]; then
        # remove version if alread installed
        /usr/bin/zypper --quiet --non-interactive remove `rpm -qp $OMD_PACKAGE`
        /usr/bin/zypper --quiet --non-interactive install $OMD_PACKAGE
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
OMD_BIN=$OMD_BIN PERL_DL_NONLAZY=1 /usr/bin/env perl "-MExtUtils::Command::MM" "-e" "test_harness($VERBOSE)" $TESTS
