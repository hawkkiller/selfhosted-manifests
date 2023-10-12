#!/bin/bash

# AWS_ACCESS_KEY_ID - AWS access key
# S3_REGION - AWS region of the S3 bucket
# S3_BUCKET - name of the S3 bucket
# AWS_SECRET_ACCESS_KEY - AWS secret key
# MYSQL_HOST - host of the MySQL server
# MYSQL_USER - user with access to MYSQL_DATABASE
# MYSQL_PASSWORD - password for MYSQL_USER
# MYSQL_DATABASE - name of the database to backup
# RETENTION_DAYS - number of days to keep backups
# BACKUP_PATH - path to store backups in S3 bucket
# DIRS_TO_BACKUP(absolute paths) - list of directories to backup, separated by space

# Algorithm:

# 1. Create a local backup folder
# 2. Dump the database to a file
# 3. Copy the directories to backup to the local backup folder
# 4. Upload the local backup folder to S3
# 5. Clean the local backup folder
# 6. Clean old backups from S3 (if any)

set -e

date_format=$(date +"%Y-%m-%d-%H-%M-%S")

local_backup_folder="backup/${date_format}"

mkdir -p "${local_backup_folder}"

local_backup_sql="${local_backup_folder}/${MYSQL_DATABASE}-${date_format}.sql.gz"

check_mysql_installation() {
  mysql --version
}

create_backup() {
  # Dump database to file
  mysqldump \
    -h "${MYSQL_HOST}" \
    -u "${MYSQL_USER}" \
    -p"${MYSQL_PASSWORD}" \
    --single-transaction "${MYSQL_DATABASE}" | gzip -9 >"${local_backup_sql}"

  # COPY DIRS_TO_BACKUP
  IFS=' ' read -ra ADDR <<< "$DIRS_TO_BACKUP"
  for dir in "${ADDR[@]}"; do
      cp -r -L "${dir}" "${local_backup_folder}"
  done
}

upload_to_s3() {
  local remote_dir
  remote_dir="s3://${S3_BUCKET}/${BACKUP_PATH}/${date_format}"

  # Copy backups to S3
  aws s3 cp "${local_backup_folder}" "${remote_dir}" --recursive
}

clean_local_backup_folders() {
  rm -rf "${local_backup_folder}"
}

clean_old_s3_backups() {
  local oldest_date
  oldest_date=$(date -d "-${RETENTION_DAYS} days" +%Y-%m-%d)

  aws s3api list-objects --bucket "${S3_BUCKET}" --query "Contents[?LastModified<='${oldest_date}'].{Key: Key}" --output text | while read -r object_key; do
    aws s3 rm "s3://${S3_BUCKET}/${object_key}"
  done
}

# Main Execution
check_mysql_installation
create_backup
upload_to_s3
clean_local_backup_folders
clean_old_s3_backups
