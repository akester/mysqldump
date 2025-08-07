# MySQL Dump

This is a container that runs mysql dump, compresses the output, then stores a
number of copies while clearing out old ones.  It's intended to be run via a
Cron and a companion to a MySQL or MariaDB container.

## Tags

Just use `latest`.  It will use MariaDB 11.4 and is updated weekly to get any
upstream changes.

## Usage

These environment variables are used to configure the container:

* `BACKUP_DAYS` - Backups older than this number of days will be removed.
  Defaults to 14.
* `BACKUP_DIR` - Directory to dump and store backups into.
* `MYSQL_HOST`, `MYSQL_USER`, `MYSQL_PASS` - Host, User and Password of the
  MySQL / MariaDB server to connect to.

This script will list the databases, then dump each one into its own file
skipping `sys`, `mysql`, etc.

You can then configure this as a cron job in Kubernetes, as an example:

```yaml
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: {{ name }}-dump-app
spec:
  schedule: "0 */8 * * *"
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: dump
            image: akester/mysqldump
            volumeMounts:
            - name: backups
              mountPath: /mnt/backups
          volumes:
          - name: backups
            persistentVolumeClaim:
              claimName: {{ name }}-backups-pvc
          restartPolicy: OnFailure
```


## Development

The container is built using Packer and has a Makefile, just run `make` to start
a build.

## Mirror

If you're looking at this repo at https://github.com/akester/mysqldump/, know
that it's a mirror of my local code repository.  This repo is monitored though,
so any pull requests or issues will be seen.