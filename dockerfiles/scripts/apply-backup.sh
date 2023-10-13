#!/bin/bash

# AWS_ACCESS_KEY_ID - AWS access key
# S3_REGION - AWS region of the S3 bucket
# S3_BUCKET - name of the S3 bucket
# AWS_SECRET_ACCESS_KEY - AWS secret key
# MYSQL_HOST - host of the MySQL server
# MYSQL_USER - user with access to MYSQL_DATABASE
# MYSQL_PASSWORD - password for MYSQL_USER
# MYSQL_DATABASE - name of the database to backup
# BACKUP_PATH - path to store backups in S3 bucket
# GHOST_PATH - path to ghost content folder (/var/lib/ghost)

# Algorithm:

# 1. Download latest backup
# 2. Restore the database from the backup
# 3. Restore the ghost content from the backup

set -e

tmp_backup="/tmp/backup"

mkdir -p "${tmp_backup}"

check_mysql_installation() {
  mysql --version
}

download_backup() {
  local latest_backup
  latest_backup=$(aws s3 ls "s3://${S3_BUCKET}/${BACKUP_PATH}/" | sort | tail -n 1 | awk '{print $2}')

  # break if no backup found
  if [ -z "${latest_backup}" ]; then
    echo "No backup found"
    exit 0
  fi

  aws s3 cp "s3://${S3_BUCKET}/${BACKUP_PATH}/${latest_backup}" "${tmp_backup}" --recursive
}

restore_backup() {
  # Restore ghost content from backup
  rsync -avz "${tmp_backup}/content" "${GHOST_PATH}/content"

  # Check if database already contains data
  if [ "$(mysql -h "${MYSQL_HOST}" -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" -e "SHOW TABLES;" | wc -l)" -gt 0 ]; then
    echo "Database already contains data"
    exit 0
  fi

  # Restore database from backup
  gunzip <"${tmp_backup}/${MYSQL_DATABASE}-*.sql.gz" | mysql -h "${MYSQL_HOST}" -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}"
}

clean_tmp_backup() {
  rm -rf "${tmp_backup}"
}

check_mysql_installation
download_backup
restore_backup
clean_tmp_backup
exit 0