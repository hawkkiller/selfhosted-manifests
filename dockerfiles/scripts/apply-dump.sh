#!/bin/bash

check_table_exists() {
    local query="SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${MYSQL_DATABASE}' AND table_name='${MYSQL_TABLE_NAME}';"
    local table_exists
    table_exists=$(mysql -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -h "${MYSQL_HOST}" -e "$query" --skip-column-names)

    return "${table_exists}"
}

download_latest_backup() {
    # Remote backup directory
    local remote_dir="s3://${S3_BUCKET}/${MY_SQL_PATH}"

    local latest_backup
    latest_backup=$(aws s3 ls "${remote_dir}" --recursive | sort | tail -n 1 | awk '{print $4}')

    if [[ -z "$latest_backup" ]]; then
        echo "No backup found in ${remote_dir}"
        exit 1
    fi

    local parent_dir
    parent_dir=$(dirname "/tmp/${latest_backup}")

    mkdir -p "$parent_dir"
    echo "Downloading ${latest_backup} from ${remote_dir}..."
    aws s3 cp "s3://${S3_BUCKET}/${latest_backup}" "/tmp/${latest_backup}"

    # Export latest_backup for use in other functions
    echo "$latest_backup"
}

apply_mysql_dump() {
    local dump_file=$1

    # MySQL data does not exist, apply the dump
    gunzip <"/tmp/${dump_file}" | mysql -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}"

    # Remove the dump file
    rm "/tmp/${dump_file}"
    echo "MySQL dump imported successfully."
}

# Main Script Execution Starts Here

check_table_exists

if [[ $? -eq 1 ]]; then
    echo "Table ${MYSQL_TABLE_NAME} exists, skipping MySQL dump import..."
    exit 0
else
    echo "Importing MySQL dump..."

    # Download backup and get the filename
    latest_backup=$(download_latest_backup)

    if [[ $? -eq 1 ]]; then
        exit 1
    fi

    apply_mysql_dump "${latest_backup}"
fi
