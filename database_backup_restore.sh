#!/usr/bin/env bash

if [ ! -n "$1" ];then
   echo "Argument 1 -- date in YYYY-MM-DD format -- not given"
   exit 1
fi

if [ ! -n "$2" ];then
   echo "Argument 2 -- database name -- not given"
   exit 1
fi

source database_backup.cfg

#build filename
FILENAME=$1_server_${IP_ADDRESS}_database_$2.sql.gz

#get specified backup file
scp $REMOTE_DIR/$FILENAME /dir/to/backup/

#unzip
gunzip -f $FILENAME

#backup what we have
BAKFILE="/dir/to/backup/tmp_$1_server_${IP_ADDRESS}_database_${1}.sql.gz"
mysqldump -uuser -ppassword $2 | gzip > $BAKFILE


#drop and recreate database
mysqladmin -uuser -ppassword  drop $2
mysqladmin -uuser -ppassword  create $2

#restore db
mysql -uuser -ppassword $2 < /dir/to/backup/$1_server_${IP_ADDRESS}_database_$2.sql