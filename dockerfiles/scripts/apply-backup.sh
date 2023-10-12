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
# GHOST_CONTENT_PATH - path to ghost content folder

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
  latest_backup=$(aws s3 ls "s3://${S3_BUCKET}/${BACKUP_PATH}/" | sort | tail -n 1 | awk '{print $4}')

  # break if no backup found
  if [ -z "${latest_backup}" ]; then
    echo "No backup found"
    exit 0
  fi

  aws s3 cp "s3://${S3_BUCKET}/${BACKUP_PATH}/${latest_backup}" "${tmp_backup}" --recursive
}

restore_backup() {
  # Restore database from backup
  gunzip <"${tmp_backup}/${MYSQL_DATABASE}-*.sql.gz" | mysql -h "${MYSQL_HOST}" -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}"

  # Restore ghost content from backup
  cp -r -L "${tmp_backup}/content" "${GHOST_CONTENT_PATH}"
}

clean_tmp_backup() {
  rm -rf "${tmp_backup}"
}

check_mysql_installation
download_backup
restore_backup
clean_tmp_backup