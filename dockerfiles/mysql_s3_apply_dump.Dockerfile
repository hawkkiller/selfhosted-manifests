FROM michaellazebny/mysql_aws

# Copy necessary scripts and files
COPY scripts/apply_dump.sh /apply_dump.sh

RUN chmod +x /apply_dump.sh

CMD ["apply_dump.sh"]
