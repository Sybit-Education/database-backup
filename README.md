# database-backup

Database-Backup is a Docker container to make regular backups from database containers and store them inside the own container. 

## Setup

### Setup Example Postgress

```yml
services:
    database-backup:
        image: ghcr.io/sybit-education/database-backup:main
        container_name: database-backup
        restart: always
        depends_on:
            - db-container-name
        volumes:
            - /data/backups:/app/backups
            - /var/run/docker.sock:/var/run/docker.sock
        environment:
            - CONTAINER=db-container-name
            - CRON=0 4 * * *
            - BACKUP_CMD=pg_dump -U db-user -d db-name > dump.sql
            - RESTORE_CMD=psql -U db-user -d db-name < dump.sql
            - DUMP_PATH=dump.sql
```

### Setup Example MongoDB

```yml
services:
    database-backup:
        image: ghcr.io/sybit-education/database-backup:main
        container_name: database-backup
        restart: always
        depends_on:
            - db-container-name
        volumes:
            - /data/backups:/app/backups
            - /var/run/docker.sock:/var/run/docker.sock
        environment:
            - CONTAINER=db-container-name
            - CRON=0 4 * * *
            - BACKUP_CMD=mongodump --gzip --archive=dump/dump.tar.gz
            - RESTORE_CMD=mongorestore --gzip --archive=dump/dump.tar.gz
            - DUMP_PATH=dump/dump.tar.gz
```

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