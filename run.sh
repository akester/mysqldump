#!/bin/bash

set -e

RETAIN="${BACKUP_DAYS:-14}"
DATE=$( date +"%Y-%m-%dT%H:%M" )

if [ "$BACKUP_DIR" == "" ]; then
    echo "No backup directory specified!"
    exit 1
fi

mkdir -p $BACKUP_DIR

DBS=$( mariadb --skip-ssl -h $MYSQL_HOST -u$MYSQL_USER -p"$MYSQL_PASS" -N -e "SHOW DATABASES;" )

for DB in $DBS; do
    if [ "$DB" = "mysql" ]; then
        continue
    fi
    if [ "$DB" = "test" ]; then
        continue
    fi
    if [ "$DB" = "information_schema" ]; then
        continue
    fi
    if [ "$DB" = "performance_schema" ]; then
        continue
    fi
    if [ "$DB" = "sys" ]; then
        continue
    fi

    echo "Creating backup of $DB..."
    FILENAME="$DB-$DATE.sql.gz"

    mariadb-dump -h $MYSQL_HOST -u$MYSQL_USER -p"$MYSQL_PASS" --single-transaction $DB | gzip > "$BACKUP_DIR"/"$FILENAME"
done

echo "Cleaning out old backups..."
find $BACKUP_DIR -mtime +$RETAIN -delete -print
