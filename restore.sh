LATEST_BACKUP="$BACKUP_DIR/latest.*"

exec > >(tee /proc/1/fd/1)
exec 2>/tmp/error.log

set -e

error() {
  echo "[RESTORE $(date +'%H:%M')] Backup failed due to an error: $(tail -n 1 /tmp/error.log)!"
  exit 1
}

trap 'error' ERR

if [ $# -eq 1 ]; then
  BACKUP_FILE="$1"
else
  BACKUP_FILE=$(ls -t $LATEST_BACKUP 2>/dev/null | head -n 1)

  if [ -z "BACKUP_FILE" ]; then
    echo "No latest backup file found in $BACKUP_DIR."
    exit 1
  fi

fi

echo "[RESTORE $(date +'%H:%M')] Starting restore on container $CONTAINER"
echo "[RESTORE $(date +'%H:%M')] Copy $BACKUP_FILE to $CONTAINER container"
docker exec $CONTAINER sh -c "mkdir -p $(dirname "$DUMP_PATH")"
docker cp $BACKUP_FILE $CONTAINER:$DUMP_PATH

echo "[RESTORE $(date +'%H:%M')] Running restore command: $RESTORE_CMD"
docker exec $CONTAINER sh -c "$RESTORE_CMD"

echo "[RESTORE $(date +'%H:%M')] Clean up $CONTAINER container"
docker exec $CONTAINER sh -c "rm -rf $DUMP_PATH"

echo "[RESTORE $(date +'%H:%M')] Restore complete!"
