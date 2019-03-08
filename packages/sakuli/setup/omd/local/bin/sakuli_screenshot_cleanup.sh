#!/bin/bash

SCREENSHOT_HIDE_AFTER=30
SCREENSHOT_DELETE_AFTER=60

LOG=${OMD_ROOT}/var/log/sakuli_screenshot_cleanup.log
IMG_ROOT=${OMD_ROOT}/var/sakuli/screenshots/

# Cleanup  ===================
pushd "$IMG_ROOT"
for d in $(ls "$IMG_ROOT") 
do
	# Change IFS to ignore spaces in path
	OIFS="$IFS"
	IFS=$'\n'
	# Hide Screenshots
	TMP_DIR=$"$IMG_ROOT""$d"
	echo "Hide screenshots from $TMP_DIR:" >> $LOG
	find "$TMP_DIR" -mindepth 2 -regex '.*[0-9]' -mtime +$SCREENSHOT_HIDE_AFTER -type d >> $LOG
	for d in $(find "$TMP_DIR" -mindepth 2 -regex '.*[0-9]' -mtime +$SCREENSHOT_HIDE_AFTER -type d);  do mv "$d" "$d.HIDDEN"; done
	
	# Delete Screenshots
	echo "Delete screenshots from $TMP_DIR:" >> $LOG
	find "$TMP_DIR" -mindepth 2 -mtime +$SCREENSHOT_DELETE_AFTER -type d >> $LOG
	for d in $(find "$TMP_DIR" -mindepth 2 -mtime +$SCREENSHOT_DELETE_AFTER -type d);  do rm -rf "$d"; done
	# Change IFS back to default
	IFS="$OIFS"
done 
exit 0
