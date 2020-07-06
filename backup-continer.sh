#!/bin/bash

export DB_CONTAINER="snipe-it" # name your container
export LOCAL_SMB_DIR="/mnt/backup-snipeit"
export REMOTE_SMB_DIR="your path folder for dst bckp" #exmp "//1.1.1.1/backup"
export NAME="snipe-it" #for calling format name backup
export DATE_CP="`date +%Y-%m-%d-%H-%M-%S -d "today"`" #calling copy file by date
export DATE_RM="`date +%Y-%m-%d-%H-%M-%S -d "2 day ago"`" #delete copying file 2 day ago
export BACKUP_DIR="/var/www/html/storage/app/backups/" #path folder backup snipeit

mkdir -p $LOCAL_SMB_DIR #create folder if doesn't exist

# should not include -ti, cron doesn't attach to any TTYs.
/bin/echo "Creating database backup for ${snipe-it} ..."
docker exec "$DB_CONTAINER" /usr/bin/php /var/www/html/artisan snipeit:backup && echo "Dump completed"

# mount smb dir
/usr/sbin/mount.cifs $REMOTE_SMB_DIR $LOCAL_SMB_DIR -o user=user_smb,pass=password_smb && echo "SMB mounted"

docker cp snipelpc:/var/www/html/storage/app/backups/$NAME-$DATE_CP.zip $LOCAL_SMB_DIR/ && echo "Backup copied"

rm -f $LOCAL_SMB_DIR/$NAME-$DATE_RM.zip

docker rm -f snipelpc:/var/www/html/storage/app/backups/$NAME-$DATE_RM.zip && echo "File Removed from Container"

umount $LOCAL_SMB_DIR && echo "SMB unmounted" && echo "Completed"

exit
