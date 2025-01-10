# database-backup

Database Backup is a Docker container to make regular backups from database containers.

## Manual Backup

A backup is scheduled by default every day at 04:00 in the morning. That can be changed with the `CRON` environment variable.
You can trigger a manual backup with the following command.

```sh
docker exec field-service-translation-backup sh -c "./backup"
```

## Restore

The backups are restored in the `/app/backups` directory. Use `docker exec field-service-translation-backup sh -c "ls /app/backups` to scout.
You can restore the latest backup with the following command.

```sh
docker exec field-service-translation-backup sh -c "./restore"
```

To restore a specific backup add the file as argument to the restore script.

```sh
docker exec field-service-translation-backup sh -c "./restore /app/backups/backup_20241129134348.tar.gz"
```