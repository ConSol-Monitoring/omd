#!/bin/bash

usage() {
    echo "Usage: $0 <path to VMware-vSphere-Perl-SDK-5.5.0-1384587.x86_64.tar.gz>" 
    echo "SDKs can be downloaded from:"
    echo ""
    echo "Perl SDK for vSphere 5.5"
    echo "https://my.vmware.com/web/vmware/details?downloadGroup=SDKPERL550&productId=353"
    echo ""
    echo "Perl SDK for vSphere 6.5"
    echo "https://my.vmware.com/group/vmware/get-download?downloadGroup=VS-PERL-SDK65"
    exit 3
}

if [ $# -lt 1 ]; then
  usage;
fi

TARBALL=$1
if ! test -e $TARBALL; then
  echo "$TARBALL not found"
  exit 3;
fi

if [ "x$OMD_ROOT" = "x" ]; then
  echo "installer must be run as as site user."
  exit 3;
fi

TARGET="$OMD_ROOT/local/lib/perl5/lib/perl5/VMware"
FILES=$(tar tvfz $TARBALL 2>&1 | grep /VMware/ | grep lib | grep .pm | awk '{print $6}')

if [ "x$FILES" = "x" ]; then
  echo "cannot find perl lib files in archive"
  exit 3;
fi

set -e
mkdir -p $TARGET
rm -f $TARGET/*.pm

echo "installing files"
echo "$FILES"
DIRDEPTH=$(echo "$FILES" | head -n 1 | sed 's/\//\n/g' | grep -v \.pm | wc -l)
tar zxf $TARBALL -C $TARGET --strip-components=$DIRDEPTH $FILES

echo "vmware perl sdk installed successfully to $TARGET"

