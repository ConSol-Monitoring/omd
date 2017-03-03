#!/bin/bash

DIR=$(dirname $0)
AHA=$(which aha 2>/dev/null)
OPTIONS=$*
if [ "x$AHA" != "x" ]; then
  AHA="$AHA --no-header"
else
  AHA="cat"
  OPTIONS="--color 0 $OPTIONS"
fi
OPTIONS="--wide --quiet --warnings batch $OPTIONS"

OUT=$($DIR/testssl.sh $OPTIONS 2>&1)
RC=$?

NAME="TESTSSL"
EXIT=0
if [[ $OUT =~ "NOT ok" ]]; then
    echo -n "$NAME CRITICAL - "
    printf "$OUT" | $AHA | grep "NOT ok" | tr '\n' ' - '
    echo ""
    EXIT=2
elif [ $RC != 0 ] || [[ $OUT =~ "-h, --help" ]]; then
    echo "$NAME UNKNOWN - testssl exited with $?"
    EXIT=3
else
    echo "$NAME OK - All tests passed"
fi

echo "Details:"
echo ""
echo "$OUT" | $AHA
exit $EXIT
