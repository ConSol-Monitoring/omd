#!/bin/bash

FILES="$*"

if [ "x$FILES" = "x" ]; then
  echo "usage: $0 <files...>"
  echo "script sorts BUILD_PACKAGES and OS_PACKAGES to make it comparable"
  exit 3
fi
TMPFILE=$(tempfile)

trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"
    echo -n "$var"
}

for FILE in $FILES; do
  if test -h $FILE; then
    echo "skipping symlinked $FILE"
    continue
  fi
  echo -n "patching $FILE..."
  for PREFIX in BUILD_PACKAGES OS_PACKAGES; do
    printf "%-20s  =\n" "$PREFIX" > $TMPFILE
    while read line; do
      pkg=$(trim ${line%%#*})
      comment=""
      if [[ $line == *"#"* ]]; then
        comment=$(trim ${line#*#})
        printf "%-20s += %-30s # %s\n" "$PREFIX" "$pkg" "$comment" >> $TMPFILE
      else
        printf "%-20s += %s\n" "$PREFIX" "$pkg" >> $TMPFILE
      fi
    done <<< $(grep ^$PREFIX $FILE | sed 's/^.*=\ *//' | sort | grep -v ^$)
    sed "/^$PREFIX\ *+=/d" -i $FILE
    sed  "s/^$PREFIX\ *=/$PREFIX/g" -i $FILE
    sed -e "/^$PREFIX$/r $TMPFILE" -i $FILE
    sed "/^$PREFIX$/d" -i $FILE
  done
  # fix intendation of other lines as well
  >$TMPFILE
  while read line; do
    key=${line%% *}
    op=$(echo $line | awk '{ print $2 }')
    rest=$(echo "$line" | sed 's/^.*=\ *//g')
    printf "%-20s %2s %s\n" "$key" "$op" "$rest" >> $TMPFILE
  done <<< $(cat $FILE)
  # remove duplicates
  cat $TMPFILE | uniq > $FILE
  # trim trailing whitespace
  sed -e 's/\ *$//g' -i $FILE
  echo " done."
done

unlink $TMPFILE
