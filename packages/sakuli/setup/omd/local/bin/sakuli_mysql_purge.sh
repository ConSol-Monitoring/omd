#!/bin/bash

# Automatic cleanup for Sakuli result tables
# add to $OMD_ROOT/etc/cron.d/sakuli: 
# 02 12 * * * $OMD_ROOT/local/bin/mysql_purge.sh 90 > /dev/null 2>&1

if [ $# -ne 1 ]
then
        echo "Wrong number of arguments. Arg 1 must be the number of days db data should be kept."
        exit 1
fi

DAYS=$1

mysql sakuli<<EOFMYSQL
DELETE FROM sakuli_suites where time < DATE_SUB(NOW(), INTERVAL $DAYS  DAY);
DELETE FROM sakuli_cases where time < DATE_SUB(NOW(), INTERVAL $DAYS DAY);
DELETE FROM sakuli_steps where time < DATE_SUB(NOW(), INTERVAL $DAYS DAY);
EOFMYSQL

echo "FLUSH QUERY CACHE;" | mysql
for db in sakuli
do
    TABLES=$(echo "USE $db; SHOW TABLES;" | mysql | grep -v 'Tables_in')
    echo "Switching to database $db."
    for table in $TABLES
    do
        echo -n "Optimizing table $table... "
        echo "USE $db; OPTIMIZE TABLE $table" |mysql
        echo "done."
    done
done
