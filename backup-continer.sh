#!/bin/bash

# export DB_HOST="localhost"
# export DB_USER="postgres"
# export DB_PASSWD="openpass"
# export DB_NAME="openfire"
export DB_CONTAINER="Your_Name_Container"
export LOCAL_SMB_DIR="Your_DST_PATH"
export REMOTE_SMB_DIR="YOUR_DST_SMB"  #example export REMOTE_SMB_DIR="//1.1.1.1/your-shared-folder"

export DATE_BACKUP="`date +%Y-%m-%d_%H-%M-%S`"
export DATE_LW="`date +%Y-%m-%d_%H-%M-%S -d "last week"`"
export BACKUP_DIR="/var/www/html/storage/app/backups/$DATE_BACKUP"

mkdir -p $LOCAL_SMB_DIR
mkdir -p $BACKUP_DIR

# should not include -ti, cron doesn't attach to any TTYs.
/bin/echo "Creating database backup for ${your-name-container-to-backup} ..."
docker exec "$DB_CONTAINER" /usr/bin/php /var/www/html/artisan snipeit:backup && echo "Dump completed"


# mount smb dir
/usr/sbin/mount.cifs $REMOTE_SMB_DIR $LOCAL_SMB_DIR -o user=user-smb,pass=passwd-smb && echo "SMB mounted"


# copy backup into remote mounted smb
docker cp name-container:/var/www/html/storage/app/backups/ $LOCAL_SMB_DIR/ && echo "Backup copied"


# remove old (1 week) backup)
#rm -f $BACKUP_DIR/$DB_NAME_$DATE_LW.7z $LOCAL_SMB_DIR/$DB_NAME_$DATE_LW.7z

# unmount the smb
umount $LOCAL_SMB_DIR && echo "SMB unmounted" && echo "Completed"
