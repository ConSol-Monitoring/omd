#!/bin/bash

. $OMD_ROOT/etc/omd/site.conf

if [ "$CONFIG_APACHE_MODE" = "shared" -a $(/usr/bin/id -un) != $OMD_SITE ]; then
    echo "cannot reload crontab in apaches shared mode."
    exit 0
fi

omd restart crontab
