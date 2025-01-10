FROM alpine:latest

RUN apk add --no-cache docker-cli
RUN apk add --no-cache tzdata

WORKDIR /app

COPY *.sh .
RUN chmod +x backup.sh
RUN chmod +x restore.sh
RUN echo "SUCCESS" > /tmp/health_status

ENV CONTAINER=my-container
ENV CRON="0 4 * * *"
ENV BACKUP_CMD="echo"
ENV RESTORE_CMD="echo"
ENV DUMP_PATH=/dump/dump.tar.gz
ENV BACKUP_DIR=/app/backups

HEALTHCHECK --interval=10s --timeout=5s \
  CMD grep -q "SUCCESS" /tmp/health_status || exit 1

CMD mkdir -p "$BACKUP_DIR" && chmod 755 "$BACKUP_DIR"  && \
    echo "$CRON /app/backup.sh --docker-log /proc/1/fd/1 2>&1" > /etc/crontabs/root && \
    echo "Backup container ready to make backups of $CONTAINER with cronjob $CRON" > /proc/1/fd/1 && \
    crond -f
