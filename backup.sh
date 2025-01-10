TIMESTAMP=$(date +"%Y%m%d%H%M")
EXTENSION="${DUMP_PATH##*/}"
EXTENSION="${EXTENSION#*.}"
LATEST_BACKUP="$BACKUP_DIR/latest.$EXTENSION"
TIMESTAMPED_BACKUP="$BACKUP_DIR/backup_$TIMESTAMP.$EXTENSION"

if [[ "$1" != "--docker-log" ]]; then
    exec > >(tee /proc/1/fd/1)
    exec 2>/tmp/error.log
else
  exec 2>/tmp/error.log
fi

set -e

error() {
  echo "FAILED" > /tmp/health_status
  echo "[BACKUP $(date +'%H:%M')] Backup failed due to an error: $(tail -n 1 /tmp/error.log)!"
  exit 1
}

trap 'error' ERR

echo "[BACKUP $(date +'%H:%M')] Starting backup on container $CONTAINER"
echo "[BACKUP $(date +'%H:%M')] Running backup command: $BACKUP_CMD"
docker exec $CONTAINER sh -c "mkdir -p $(dirname "$DUMP_PATH")"
docker exec $CONTAINER sh -c "$BACKUP_CMD"

echo "[BACKUP $(date +'%H:%M')] Copy backup from $CONTAINER container as $LATEST_BACKUP"
rm -rf $LATEST_BACKUP
docker cp $CONTAINER:$DUMP_PATH $LATEST_BACKUP

echo "[BACKUP $(date +'%H:%M')] Create local backup file $TIMESTAMPED_BACKUP"
cp -r $LATEST_BACKUP $TIMESTAMPED_BACKUP

echo "[BACKUP $(date +'%H:%M')] Clean up old backups"
find $BACKUP_DIR -type d -name "backup_*" -mtime +7 -exec rm -rf {} \;

echo "[BACKUP $(date +'%H:%M')] Clean up $CONTAINER container"
docker exec $CONTAINER sh -c "rm -rf $DUMP_PATH"

echo "SUCCESS" > /tmp/health_status
echo "[BACKUP $(date +'%H:%M')] Backup complete!"
