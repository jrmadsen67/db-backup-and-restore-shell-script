#!/usr/bin/env bash

source database_backup.cfg

#first, let's confirm the new files are being transferred so we don't just grind through the backups deleting
NOW=$(date +"%Y-%m-%d")
COUNT=$(ls ${NOW}* | wc -l)

if [ $COUNT -lt 1 ];then

   EMAIL_MSG="dailyemail.txt"
   EMAIL_SUBJECT="Today's backups not saved!:${NOW}"
   EMAIL_RECIPIENT="${EMAIL_RECIPIENT}"

   echo "The cleanup script was unable to find any backups for today's date. Please check the backup scripts!" >> EMAIL_MSG

   mail -s "${EMAIL_SUBJECT}" "${EMAIL_RECIPIENT}" < $EMAIL_MSG
   rm $EMAIL_MSG

   exit 1
fi


# now it's safe - clean up
DELETE_DAYS=8
OLD_DATE=$(date --date="${DELETE_DAYS} days ago" +"%Y-%m-%d")

rm -f ${OLD_DATE}*
