#!/bin/bash

#
# default traphandle script
#

LOGFILE=$1
if [ -z "$LOGFILE" ]; then
    echo "usage: $0 <logfile>"
    exit 1
fi

if [ -f "$OMD_ROOT/etc/environment" ]
then
    set -a
    # read SNMP_TRAPHANDLE_IGNORE_OIDS and SNMP_TRAPHANDLE_SUMMARY_ONLY
    . "$OMD_ROOT/etc/environment"
    set +a
fi

# SNMP_TRAPHANDLE_IGNORE_OIDS is a comma-separated list of oids (with leading .)
# e.x. ".1.3.6.1.4.1.25461.2.1.3.2.0.1550,.1.3.6.1.4.1.25461.2.1.3.2.0.3302,..."
# Create an array.
if [ -n "$SNMP_TRAPHANDLE_IGNORE_OIDS" ]; then
    IFS=',' read -r -a IGNORE_OID_ARRAY <<< "$SNMP_TRAPHANDLE_IGNORE_OIDS"
fi

# Like the date command, but pure bash
DATE=$(printf '%(%a %b %d %I:%M:%S %p %Z %Y)T')

# The first two variables of a trap are always the hostname and ip:port->ip:port
read -r HOST
read -r IP

# Initialize ALLINONE with the host and IP, separated by "____"
ALLINONE="____${HOST}____${IP}"
LOG_CONTENT=""

# Read key-value pairs from the subsequent lines of the trap
while read -r OID VAL; do
  # Trim any leading/trailing whitespace characters (tabs, carriage returns, newlines)
  NVAL=${VAL//[$'\t\r\n']}
  NOID=${OID//[$'\t\r\n']}

  # .1.3.6.1.6.3.1.1.4.1.0 is followed by the actual trap oid
  if [ "$NOID" = ".1.3.6.1.6.3.1.1.4.1.0" ]; then
    # If SNMP_TRAPHANDLE_IGNORE_OIDS is set, check if this one has to be ignored.
    if [ -n "$SNMP_TRAPHANDLE_IGNORE_OIDS" ]; then
      for OID_IN_LIST in "${IGNORE_OID_ARRAY[@]}"; do
        if [ "$NVAL" = "$OID_IN_LIST" ]; then
          # If a match is found, exit without writing to the log file
          exit 0
        fi
      done
    fi
  fi

  # Add each OID and VAL pair to the log content if no match was found
  LOG_CONTENT+="[$DATE] $NOID: $NVAL\n"

  # Accumulate all the entries into one string with "____" as the separator
  ALLINONE="${ALLINONE}____$NOID $NVAL"
done

# Add a summary line to the log content
LOG_CONTENT+="[$DATE] summary: $ALLINONE\n"

# Write only the summary line if SNMP_TRAPHANDLE_SUMMARY_ONLY is set
if [ -n "$SNMP_TRAPHANDLE_SUMMARY_ONLY" ]; then
    echo -e "[$DATE] summary: $ALLINONE" >> "$LOGFILE"
else
    echo -e "$LOG_CONTENT" >> "$LOGFILE"
fi

exit 0
