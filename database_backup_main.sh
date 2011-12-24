#!/usr/bin/env bash

if [ ! -n "$1" ];then
   echo "Argument 1 -- database name -- not given"
   exit 1
fi

source database_backup.cfg

NOW=$(date +"%Y-%m-%d")
TIME=$(date +"%H:%M:%S")

BAKFILE="/dir/to/backup/database_backups/${NOW}_server_${IP_ADDRESS}_database_${1}.sql.gz"
LOGFILE="/dir/to/backup/database_backup_logs/${NOW}_log"
EMAIL_MSG="dailyemail.txt"
EMAIL_SUBJECT="Database backup results:${NOW}"



#terrible patch, I know - last minute change to handle two db's in our system
if [ $1 eq "misc_data" ]; then
   USER="user1"
   PASSWD="password1"
else
   USER="user2"
   PASSWD="password2"  
fi




mysqldump -u${USER} -p${PASSWD} $1 | gzip > $BAKFILE

if [ ! -f $BAKFILE ];then
  echo "Backup file ${BAKFILE} not created" >> $EMAIL_MSG
  echo "${TIME}:Backup file ${BAKFILE} not created" >> $LOGFILE
  EMAIL_SUBJECT="WARNING! BACKUP FAILURE"
fi

#send to backup server
scp $BAKFILE $REMOTE_DIR
OUT=$?
if [ $OUT = 0 ] ;then
  echo "transfer ${BAKFILE} successful"  >> $EMAIL_MSG
  echo "${TIME}:transfer ${BAKFILE} successful"  >> $LOGFILE

else
  echo "scp ${BAKFILE} transfer failed"  >> $EMAIL_MSG
  echo "${TIME}:scp ${BAKFILE} transfer failed"  >> $LOGFILE
  EMAIL_SUBJECT="WARNING! BACKUP FAILURE"
fi

#after we confirm scp sent, remove
rm $BAKFILE

#now let's email someone

echo "Date: ${NOW}" >> $EMAIL_MSG
echo "File: ${BAKFILE}" >> $EMAIL_MSG

mail -s "${EMAIL_SUBJECT}" "${EMAIL_RECIPIENT}" < $EMAIL_MSG
rm $EMAIL_MSG
