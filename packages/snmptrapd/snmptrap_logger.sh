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
ALLINONE=""
while read VAR; do
  NVAR=${VAR//[$'\t\r\n']}
  #printf "[%s] %s\n" "$DATE" "$VAR" >> $LOGFILE
  printf "[%s] %s\n" "$DATE" "$NVAR" >> $LOGFILE
  #ALLINONE="${ALLINONE}_,_$VAR"
  ALLINONE="${ALLINONE}____$NVAR"
done
printf "[%s] summary: %s\n" "$DATE" "$ALLINONE" >> $LOGFILE

