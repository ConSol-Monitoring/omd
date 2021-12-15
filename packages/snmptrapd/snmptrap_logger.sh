#!/bin/bash

#
# default traphandle script
#

LOGFILE=$1
if [ -z $LOGFILE ]; then
    echo "usage: $0 <logfile>"
    exit 1
fi
DATE=`date`
# dreckslinux1: Wed Dec 15 13:21:05 UTC 2021
# dreckslinux2: Wed 15 Dec 2021 02:21:02 PM CET
ALLINONE=""
while read VAR; do
  NVAR=${VAR//[$'\t\r\n']}
  printf "[%s] %s\n" "$DATE" "$NVAR" >> $LOGFILE
  ALLINONE="${ALLINONE}____$NVAR"
done
printf "[%s] summary: %s\n" "$DATE" "$ALLINONE" >> $LOGFILE

