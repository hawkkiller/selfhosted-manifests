FROM michaellazebny/mysql_aws_base

# Copy necessary scripts and files
COPY scripts/upload_dump.sh /upload_dump.sh

RUN chmod +x /upload_dump.sh

CMD ["upload_dump.sh"]
